// vars/updateGitops.groovy
//
// GitOps writeback: commit yq-path updates (typically image tags / digests)
// to a Forgejo-hosted manifests repository so ArgoCD/Flux pick them up.
//
// Thin wrapper over the `gitops.just` recipes — all heavy lifting (clone,
// idempotency, edit, rebase-retry push, PR open) lives in the just module so
// developers can reproduce a promotion locally with the same commands Jenkins
// runs. This file only handles Jenkins-specific concerns (credentials, env
// plumbing).
//
// Required just import in the consumer's justfile:
//   mod gitops '.ci/gitops.just'
//
// `imageTag` in the examples below is captured from `container.push(config)`'s
// return value (the actual `git_tag` the push recipe published) at script
// scope: declare `def imageTag` outside `pipeline { ... }`, assign in the Push
// stage, consume here. See examples/Jenkinsfile.gitops-{push,pr}.groovy.
//
// Usage (direct push):
//   updateGitops(
//     repo:          'git@forgejo.example.com:zdt/infra.git',
//     branch:        'main',
//     credentialsId: 'infra-repo-deploy-key',           // SSH key
//     updates: [
//       'apps/payments/values.yaml': [
//         '.image.tag'    : imageTag,
//         '.image.digest' : env.IMAGE_DIGEST,
//       ],
//     ],
//   )
//
// Usage (PR-gated, Forgejo):
//   updateGitops(
//     repo:               'https://forgejo.example.com/zdt/infra.git',
//     branch:             'main',
//     credentialsId:      'gitea-jenkins-password',     // userpass for HTTPS clone
//     mode:               'pr',
//     tokenCredentialsId: 'gitea-jenkins-password',     // userpass for Forgejo API
//     prBranch:           "promote/payments-${env.BUILD_NUMBER}",
//     prTitle:            "Promote payments to ${imageTag}",
//     prBody:             "Built by ${env.BUILD_URL}",
//     updates: [...],
//   )
//
// credentialsId resolves by repo URL scheme:
//   - `git@host:...` or `ssh://...` → SSH key credential, used via sshagent
//   - `https://...`                 → username/password credential, used via
//                                     gitUsernamePassword (sets up GIT_ASKPASS;
//                                     no token leakage into URL or .git/config)
//
// For PR mode `tokenCredentialsId` must be a username/password credential
// (typically the same `gitea-jenkins-password`, a consumer-provisioned Jenkins
// credential whose ID is kept for back-compat) used as a Forgejo API token.
//
// Returns: [sha: String, branch: String, prUrl: String]

def call(Map args) {
    ['repo', 'branch', 'credentialsId', 'updates'].each { k ->
        assert args[k], "updateGitops: '${k}' is required"
    }
    assert args.updates instanceof Map && !args.updates.isEmpty(),
        "updateGitops: 'updates' must be a non-empty Map<String, Map<String,String>>"
    args.updates.each { file, paths ->
        assert paths instanceof Map && !paths.isEmpty(),
            "updateGitops: '${file}' must map to a non-empty Map<String,String>"
        paths.each { p, v ->
            assert p && v, "updateGitops: empty key or value for ${file} (${p}=${v})"
        }
    }

    String repo          = args.repo.toString()
    String branch        = args.branch.toString()
    String credentialsId = args.credentialsId.toString()
    String mode          = (args.mode ?: 'push').toString()
    assert mode in ['push', 'pr'], "updateGitops: 'mode' must be 'push' or 'pr'"

    String name    = args.committer?.name  ?: 'jenkins-ci'
    String email   = args.committer?.email ?: 'jenkins@ci.local'

    String tag = UUID.randomUUID().toString().take(8)
    String updatesFile = "${env.WORKSPACE}/.gitops-updates-${tag}.json"
    writeJSON file: updatesFile, json: args.updates

    String message = (args.message ?: defaultCommitMessage(args.updates)).toString()

    String prBranch = ''
    String prTitle  = ''
    String prBody   = ''
    String tokenCredentialsId = ''
    if (mode == 'pr') {
        tokenCredentialsId = (args.tokenCredentialsId ?: '').toString()
        assert tokenCredentialsId,
            "updateGitops: 'tokenCredentialsId' is required for PR mode"
        prBranch = (args.prBranch ?: "ci/promote-${env.JOB_BASE_NAME}-${env.BUILD_NUMBER}").toString()
        prTitle  = (args.prTitle  ?: message.readLines().first()).toString()
        prBody   = (args.prBody   ?: "Automated promotion from ${env.BUILD_URL ?: 'CI'}").toString()
    }

    def envVars = [
        "GIT_USER_NAME=${name}",
        "GIT_USER_EMAIL=${email}",
        "GITOPS_COMMIT_MESSAGE=${message}",
    ]

    String sha = ''
    String prBranchArg = mode == 'pr' ? "'${prBranch}'" : "''"
    String updateCmd = "just gitops::update '${repo}' '${branch}' '${updatesFile}' '${mode}' ${prBranchArg}"

    try {
        if (repo.startsWith('git@') || repo.startsWith('ssh://')) {
            sshagent(credentials: [credentialsId]) {
                withEnv(envVars) {
                    sha = sh(returnStdout: true, script: updateCmd).trim()
                }
            }
        } else if (repo.startsWith('https://')) {
            withCredentials([gitUsernamePassword(credentialsId: credentialsId)]) {
                withEnv(envVars) {
                    sha = sh(returnStdout: true, script: updateCmd).trim()
                }
            }
        } else {
            error("updateGitops: unsupported repo URL scheme — must be SSH (git@/ssh://) or HTTPS")
        }
    } finally {
        sh "rm -f '${updatesFile}'"
    }

    def result = [sha: sha, branch: (mode == 'pr' ? prBranch : branch), prUrl: '']

    if (mode == 'pr' && sha) {
        result.prUrl = forgejo.openPullRequest(
            repoUrl:       repo,
            credentialsId: tokenCredentialsId,
            base:          branch,
            head:          prBranch,
            title:         prTitle,
            body:          prBody,
        )
    }

    if (sha) {
        echo "Infra repo updated: sha=${result.sha} branch=${result.branch}" +
             (result.prUrl ? " pr=${result.prUrl}" : '')
    } else {
        echo "Infra repo unchanged - no fields differed from desired values"
    }
    return result
}

def defaultCommitMessage(Map updates) {
    int fileCount = updates.size()
    int pathCount = (int) updates.values().sum { it.size() }
    String header = "ci: update ${pathCount} field(s) across ${fileCount} file(s)"
    String body = updates.collect { file, paths ->
        String lines = paths.collect { k, v -> "  - ${k} = ${v}" }.join('\n')
        "${file}:\n${lines}"
    }.join('\n')
    return "${header}\n\n${body}"
}
