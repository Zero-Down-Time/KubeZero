// seedMultiJob — Job DSL seed for the monorepo "one Multibranch job per service"
// pattern. Auto-targets the consuming repo (the seed job's own SCM) and generates
// one multibranchPipelineJob per service subfolder, each with its own scriptPath.
//
// Two ways to wire the consumer seed (both auto-target the consumer repo):
//   1. Dedicated Pipeline-script-from-SCM job → 2-line wrapper (examples/seedJob.groovy).
//   2. The consumer repo's ROOT Jenkinsfile under a Multibranch / Org-Folder job —
//      auto-discovered like any other repo. The guard below seeds only from the
//      primary branch, so the per-service subfolder Jenkinsfiles (which the folder
//      scan ignores at root) get generated without the seed firing on every PR.
// Either way the file is just:
//
//   @Library('ci-tools-lib') _
//   seedMultiJob()
//
// Because the seed's own SCM is the consumer repo, `checkout scm` + env.GIT_URL
// describe the consumer; forgejo.parseGitUrl derives server/owner/repo from them
// — nothing about the target is configured. Re-running reconciles: new service
// folder → new job; removed folder → job deleted (removedJobAction: 'DELETE').
//
// This is a Jenkins-only concern (job generation), so it lives in Groovy, not a
// *.just module — no developer runs it locally.
//
// config (all optional):
//   jobFolder     Jenkins folder for the generated jobs        (default: "<org>-jobs/<repo>",
//                 derived from JOB_NAME — the org's computed Gitea Org Folder can't hold
//                 manual items, so jobs go in a PARALLEL plain folder beside it)
//   discoveryGlob glob identifying a service Jenkinsfile       (default '*/Jenkinsfile';
//                 widen for nested layouts, e.g. 'services/*/Jenkinsfile' — the service
//                 dir path is preserved as the Jenkins folder hierarchy)
//   credentialsId credential the GENERATED jobs CLONE with     (default 'gitea-jenkins-password';
//                 this is the SCM clone credential — often a PAT distinct from the REST one,
//                 e.g. ZDT uses 'gitea-jenkins-pat')
//
// Always runs on the controller (label 'admin-dsl', Exclusive mode) — it only
// mutates job config and must not consume an agent executor.
//
// Requires plugins: Job DSL, Gitea, Pipeline Utility Steps. GiteaSCMSource carries
// no @Symbol, so the branch source is injected as raw XML via a `configure {}` block
// (the dynamic DSL can't express a symbol-less describable); its traits do have symbols.
// Needs Job DSL script security disabled (the step runs sandbox:false on the controller).

def call(Map config = [:]) {
    // Safe to use as the consumer repo's ROOT Jenkinsfile under a Multibranch /
    // Org-Folder job: seed only from the primary (default) branch, never on PRs or
    // feature branches, which would churn or regenerate jobs from the wrong layout.
    // A dedicated seed Pipeline job has no multibranch context (BRANCH_NAME unset),
    // so this guard is a no-op there.
    if (env.CHANGE_ID) {
        echo "seedMultiJob: skipping — pull request ${env.CHANGE_ID}"
        return
    }
    if (env.BRANCH_NAME && env.BRANCH_IS_PRIMARY != 'true') {
        echo "seedMultiJob: skipping — non-primary branch '${env.BRANCH_NAME}'"
        return
    }

    def discoveryGlob = config.discoveryGlob ?: '*/Jenkinsfile'
    def credentialsId = config.credentialsId ?: 'gitea-jenkins-password'

    // The seed is stateless — every run fully reconciles the jobs, so old builds
    // have no revert/diagnostic value beyond the last few. Keep almost no history.
    properties([
        disableConcurrentBuilds(),
        buildDiscarder(logRotator(numToKeepStr: '3')),
    ])

    // Pin to the controller: this only mutates Jenkins job config (Job DSL), never
    // builds anything, and must not consume an agent executor. The controller node
    // is in Exclusive mode under label 'admin-dsl', so request that label explicitly.
    node('admin-dsl') {
        def services
        def repo
        def jobFolder

        stage('Resolve target + discover') {
            // The seed's own SCM is the consuming repo, so this checkout AND
            // env.GIT_URL belong to the consumer — the target is derived, not
            // configured. changelog/poll off: a seed run has no diff worth tracking.
            def scmVars = checkout(scm: scm, changelog: false, poll: false)
            def parsed  = forgejo.parseGitUrl(scmVars.GIT_URL)
            if (!parsed) {
                error("seedMultiJob: could not derive the target repo from GIT_URL='${scmVars.GIT_URL}'. " +
                      "Is this seed's SCM the consumer repo?")
            }
            repo = [serverUrl: parsed.forgejoUrl, owner: parsed.owner, name: parsed.repo]
            // The org folder (e.g. ZeroDownTime) is a computed Gitea Org Folder and can't
            // hold manually-created items, so generated jobs go in a PARALLEL plain folder
            // "<org>-jobs/<repo>" rather than inside it. Derive the org path from JOB_NAME:
            // as a multibranch root-Jenkinsfile seed it is "<org…>/<repo-multibranch>/<branch>",
            // so dropping the last two segments yields the org path.
            def parts   = (env.JOB_NAME ?: '').tokenize('/')
            def orgPath = parts.size() >= 3 ? parts[0..<(parts.size() - 2)].join('/') : ''
            jobFolder   = config.jobFolder ?: (orgPath ? "${orgPath}-jobs/${repo.name}" : "${repo.name}-jobs")

            // A service is the directory holding a Jenkinsfile (svcPath, relative to
            // repo root) — may be nested (e.g. 'services/api-users') for wider globs.
            // Filter on the original path: must be in a subdir (not the repo-root seed
            // Jenkinsfile) and not under the .ci submodule.
            services = findFiles(glob: discoveryGlob)
                .collect { it.path }
                .findAll { it.contains('/') && !it.startsWith('.ci/') }
                .collect { it.replaceFirst('/Jenkinsfile$', '') }
                .unique()
                .sort()
            if (!services) {
                error("seedMultiJob: no services found matching '${discoveryGlob}'. Nothing to generate.")
            }
            echo "seedMultiJob: ${repo.owner}/${repo.name} → folder '${jobFolder}', ${services.size()} service(s): ${services.join(', ')}"
        }

        stage('Generate jobs') {
            // One multibranchPipelineJob per service. The generated jobs discover
            // branches themselves, so only server/owner/repo (not branch) are
            // needed; the ONLY per-service difference is scriptPath. Assembled with
            // collect/join (no StringBuilder/<<, which the Groovy sandbox rejects).
            // Create every ancestor folder explicitly — Job DSL doesn't auto-create
            // intermediates, "<org>-jobs" is a new top-level plain folder, and nested
            // services (e.g. services/api-users) add deeper levels. Union of all job
            // paths' ancestors, deduped, parents before children. Use .add (not <<,
            // which the Groovy sandbox rejects).
            def folderPaths = []
            services.each { svcPath ->
                def segs = "${jobFolder}/${svcPath}".tokenize('/')
                (1..<segs.size()).each { n -> folderPaths.add(segs[0..<n].join('/')) }
            }
            folderPaths = folderPaths.unique().sort { it.tokenize('/').size() }
            def header = folderPaths.collect { p ->
                p == jobFolder ? "folder('${p}') { description('Container builds generated by seedMultiJob.') }"
                               : "folder('${p}')"
            }.join('\n')

            def jobs = services.collect { svcPath ->
                def svcName  = svcPath.tokenize('/').last()        // leaf — readable display name
                def sourceId = "${repo.name}-${svcPath}".replaceAll('[^a-zA-Z0-9_.-]', '-')
                """
multibranchPipelineJob('${jobFolder}/${svcPath}') {
    displayName('${svcName}')
    factory { workflowBranchProjectFactory { scriptPath('${svcPath}/Jenkinsfile') } }
    orphanedItemStrategy { discardOldItems { numToKeep(10) } }
    triggers { periodicFolderTrigger { interval('1d') } }   // backstop; webhooks drive real-time scans
    // GiteaSCMSource has no @Symbol, so the dynamic DSL can't express it. Inject the
    // branch source as raw XML via configure — the sanctioned job-dsl escape hatch.
    configure { project ->
        (project / 'sources' / 'data') << {
            'jenkins.branch.BranchSource' {
                source(class: 'org.jenkinsci.plugin.gitea.GiteaSCMSource') {
                    id('${sourceId}')
                    serverUrl('${repo.serverUrl}')
                    repoOwner('${repo.owner}')
                    repository('${repo.name}')
                    credentialsId('${credentialsId}')
                    traits {
                        'org.jenkinsci.plugin.gitea.BranchDiscoveryTrait' { strategyId(1) }
                        'org.jenkinsci.plugin.gitea.OriginPullRequestDiscoveryTrait' { strategyId(1) }
                        'org.jenkinsci.plugin.gitea.ForkPullRequestDiscoveryTrait' {
                            strategyId(1)
                            trust(class: 'org.jenkinsci.plugin.gitea.ForkPullRequestDiscoveryTrait\$TrustContributors')
                        }
                        'org.jenkinsci.plugin.gitea.TagDiscoveryTrait'()   // releases arrive as tags
                        // .ci is a submodule — recurse so service builds get the library
                        'jenkins.plugins.git.traits.SubmoduleOptionTrait' {
                            extension(class: 'hudson.plugins.git.extensions.impl.SubmoduleOption') {
                                disableSubmodules(false)
                                recursiveSubmodules(true)
                                trackingSubmodules(false)
                                reference('')
                                parentCredentials(false)
                                shallow(false)
                            }
                        }
                    }
                }
                strategy(class: 'jenkins.branch.DefaultBranchPropertyStrategy') {
                    properties(class: 'empty-list')
                }
            }
        }
    }
}
"""
            }

            // sandbox:false — the generated DSL runs with full privilege
            jobDsl(
                scriptText:        ([header] + jobs).join('\n'),
                sandbox:           false,
                lookupStrategy:    'JENKINS_ROOT',   // names are absolute from root — the seed runs inside a
                                                     // multibranch project (root Jenkinsfile), which can't hold child jobs.
                                                     // Pruning is still scoped to this seed's generated set.
                removedJobAction:  'DELETE',     // drop jobs for services that disappeared
                removedViewAction: 'DELETE',
            )
        }
    }
}
