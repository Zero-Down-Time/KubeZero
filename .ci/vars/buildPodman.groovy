// Common container builder by ZeroDownTime

def call(Map config=[:]) {
    pipeline {
      options {
        disableConcurrentBuilds()
      }
      agent {
        node {
          label 'podman-aws-grype'
        }
      }
      stages {
        stage('Prepare') {
          steps {
            sh 'mkdir -p reports'

            // we set pull tags as project adv. options
            // pull tags
            //withCredentials([gitUsernamePassword(credentialsId: 'gitea-jenkins-user')]) {
            //  sh 'git fetch -q --tags ${GIT_URL}'
            //}
            // Optional project specific preparations
            sh 'make prepare'
          }
        }

        // Build using rootless podman
        stage('Build') {
          steps {
            sh 'make build GIT_BRANCH=$GIT_BRANCH'
          }
        }

        stage('Test') {
          steps {
            sh 'make test'
          }
        }

        // Scan via trivy
        stage('Scan') {
          steps {
            // we always scan and create the full json report
            sh 'GRYPE_OUTPUT=json GRYPE_FILE="reports/grype-report.json" make scan'

            // fail build if grypeFail is set, default is any ERROR marks build unstable
            script {
              def failBuild=config.grypeFail
              if (failBuild == null || failBuild.isEmpty()) {
                  recordIssues enabledForFailure: true, tool: grype(), sourceCodeRetention: 'NEVER', skipPublishingChecks: true, qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', criticality: 'NOTE']]
              } else {
                  recordIssues enabledForFailure: true, tool: grype(), sourceCodeRetention: 'NEVER', skipPublishingChecks: true, qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', criticality: 'FAILURE']]
              }
            }
          }
        }

        // Push to container registry if not PR
        // incl. basic registry retention removing any untagged images
        stage('Push') {
          when { not { changeRequest() } }
          steps {
            sh 'make push'
            sh 'make rm-remote-untagged'
          }
        }

        // generic clean
        stage('cleanup') {
          steps {
            sh 'make clean'
          }
        }
      }
    }
}
