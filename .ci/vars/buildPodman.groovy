// Common container builder by ZeroDownTime

def call(Map config=[:]) {
    def buildOnly = config.buildOnly ?: ['.*']
    def debug = config.debug ?: false
    def force_build = config.force_build ?: false

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
            // create and stash changeSet
            script {
              def files = forgejo.getChangeset(debug: debug)
              writeJSON file: 'changeSet.json', json: files
              stash includes: 'changeSet.json', name: 'changeSet'
            }

            // Overwrite build files from the target/origin branch
            protectBuild(files: ['Makefile', '.ci/**'])

            // Optional project specific preparations
            sh 'mkdir -p reports'
            sh 'make prepare'
          }
        }

        stage('Lint') {
          steps {
            sh 'make lint'
          }
        }

        // Build using rootless podman
        stage('Build') {
          steps {
            script {
              unstash 'changeSet'
              def files = readJSON file: "changeSet.json"

              if (force_build || forgejo.pathsChanged(files: files, patterns: buildOnly, debug: debug)) {
                sh 'make build GIT_BRANCH=$GIT_BRANCH'
              } else {
                echo("No changed files matching any of: ${buildOnly.join(', ')}. No build required.")
                currentBuild.description = 'SKIP'
              }
            }
          }
        }

        stage('Test') {
          when {
            expression { currentBuild.description != 'SKIP' }
          }
          steps {
            sh 'make test'
          }
        }

        // Scan using grype
        stage('Scan') {
          when {
            expression { currentBuild.description != 'SKIP' }
          }
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
          when {
            expression { currentBuild.description != 'SKIP' }
            expression { currentBuild.currentResult != 'FAILURE' }
            not { changeRequest() }
          }
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
