// examples/Jenkinsfile.gitops-push.groovy
//
// Direct-push GitOps promotion: after a successful container build/push,
// commit the new image tag(s) directly to a Forgejo-hosted manifests repo
// so ArgoCD picks them up on its next sync.
//
// Composes the `container.<stage>` helpers directly (instead of using the
// all-in-one `justContainer` step) so the GitOps promotion can run as its
// own stage between Push and Cleanup. For container-only projects without
// GitOps, call `justContainer(config)` at the top level instead.
//
// The consumer's root justfile must import the gitops module:
//   mod gitops '.ci/gitops.just'

@Library('ci-tools-lib') _

def config = [
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
        stage('Prepare') { steps { script { container.prepare(config) } } }
        stage('Lint')    { steps { script { container.lint(config) } } }

        stage('Build') {
            when { expression { currentBuild.currentResult != 'FAILURE' } }
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

        stage('Promote via GitOps') {
            when {
                expression { currentBuild.description != 'SKIP' }
                expression { currentBuild.currentResult != 'FAILURE' }
                not { changeRequest() }
            }
            steps {
                script {
                    def res = updateGitops(
                        repo:          'git@git.zero-downtime.net:zdt/infra.git',
                        branch:        'main',
                        credentialsId: 'infra-repo-deploy-key',
                        updates: [
                            'apps/payments/values.yaml': [
                                '.image.tag': imageTag,
                            ],
                        ],
                    )
                    echo "GitOps commit: ${res.sha} (tag: ${imageTag})"
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

    post { cleanup { sh "rm -rf ${TMP_DIR}" } }
}
