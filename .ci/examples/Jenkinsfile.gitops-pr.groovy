// examples/Jenkinsfile.gitops-pr.groovy
//
// PR-gated GitOps promotion against Forgejo. Use when the manifests repo
// requires human review before ArgoCD syncs. The PR branch is reused on
// re-runs of the same build (idempotent: existing open PR URL is returned).
//
// Composes the `container.<stage>` helpers directly (instead of using the
// all-in-one `justContainer` step) so the PR-open promotion can run as its
// own stage between Push and Cleanup.
//
// The service justfile (services/payments/.justfile) must import the gitops module:
//   mod gitops '../../.ci/gitops.just'

@Library('ci-tools-lib') _

def config = [
    workDir:     'services/payments',
    imageName:   'payments',
    registry:    '1234567890.dkr.ecr.eu-central-1.amazonaws.com',
    buildOnly:   ['services/payments/.*', '\\.ci/.*'],
    needBuilder: true,
]

// Captured from container.push() — the actual git_tag the push recipe published
// (e.g. 'v1.2.3' on a tagged commit, or 'v1.2.3-5-gabc123' otherwise).
def imageTag

pipeline {
    options { disableConcurrentBuilds() }
    agent { node { label 'podman-aws-grype' } }
    environment { TMP_DIR = '_tmp' }

    stages {
        // Changeset gate: sets the SKIP flag when no changed file matches buildOnly,
        // which every downstream stage's `when` reads. Without it, buildOnly is inert.
        stage('Changeset') { steps { script { container.changeset(config) } } }

        stage('Prepare') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.prepare(config) } }
        }

        stage('Lint') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.lint(config) } }
        }

        stage('Build') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.build(config) } }
        }

        stage('Test') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.test(config) } }
        }

        stage('Scan') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.scan(config) } }
        }

        stage('Push') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
                not { changeRequest() }
            }
            steps { script { imageTag = container.push(config) } }
        }

        stage('Open promotion PR') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
                not { changeRequest() }
            }
            steps {
                script {
                    def res = updateGitops(
                        repo:               'https://git.zero-downtime.net/zdt/infra.git',
                        branch:             'main',
                        credentialsId:      'gitea-jenkins-password',
                        mode:               'pr',
                        tokenCredentialsId: 'gitea-jenkins-password',
                        prBranch:           "promote/payments-${env.BUILD_NUMBER}",
                        prTitle:            "Promote payments to ${imageTag}",
                        prBody:             "Automated promotion. Build: ${env.BUILD_URL}",
                        updates: [
                            'apps/payments/values.yaml': [
                                '.image.tag': imageTag,
                            ],
                        ],
                    )
                    if (res.prUrl) {
                        echo "PR: ${res.prUrl}"
                        currentBuild.description = "PR: ${res.prUrl}"
                    }
                }
            }
        }

        stage('cleanup') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
            }
            steps { script { container.clean(config) } }
        }
    }

    post {
        cleanup {
            // needBuilder:true creates a reusable builder container — tear it down.
            script { container.cleanBuilder(config) }
            dir(config.workDir ?: '.') { sh "rm -rf ${TMP_DIR}" }
            // Prune finished SKIP builds from history (default on).
            script { container.pruneSkippedBuilds(config) }
        }
    }
}
