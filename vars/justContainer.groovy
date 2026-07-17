// just based container builder — thin wrapper composing the per-stage helpers

def call(Map config = [:]) {
    pipeline {
      options {
        disableConcurrentBuilds()
      }
      agent {
        node {
          label 'podman-aws-grype'
        }
      }
      parameters {
        booleanParam(name: 'FORCE_BUILD', defaultValue: false, description: 'Run all stages even when no source paths matched buildOnly')
      }
      environment {
        TMP_DIR = "_tmp"
      }
      stages {
        stage('Changeset') {
          steps {
            script {
              container.changeset(config + [forceBuild: (params.FORCE_BUILD == true) || (config.forceBuild ?: false)])
              notify.start(config)
            }
          }
        }

        stage('Prepare') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.prepare(config) }
          }
        }

        stage('Lint') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.lint(config) }
          }
        }

        stage('Build') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.build(config) }
          }
        }

        stage('Test') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.test(config) }
          }
        }

        stage('Scan') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.scan(config) }
          }
        }

        stage('Push') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
            not { changeRequest() }
          }
          steps {
            script { container.push(config) }
          }
        }

        stage('cleanup') {
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
          }
          steps {
            script { container.clean(config) }
          }
        }
      }

      post {
        always {
          script { notify.end(config) }
        }
        cleanup {
          script { container.cleanBuilder(config) }
          dir(config.workDir ?: '.') {
            sh "rm -rf ${TMP_DIR}"
          }
          // Prune finished SKIP builds from history (default on).
          script { container.pruneSkippedBuilds(config) }
        }
      }
    }
}
