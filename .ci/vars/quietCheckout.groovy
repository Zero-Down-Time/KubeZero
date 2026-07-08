// Quiet SCM checkout - reduces noisy git plugin console output
// Replaces the default checkout with manual git CLI using --quiet flags
// while replicating what the Git plugin actually does:
//   fetch (with refspecs, prune) -> checkout commit -> branch setup -> lfs pull

def call(Map config=[:]) {
    def remoteConfig = scm.userRemoteConfigs[0]
    def url = remoteConfig.url
    def credId = remoteConfig.credentialsId
    def refspec = remoteConfig.refspec ?: '+refs/heads/*:refs/remotes/origin/*'
    def lfs = config.lfs != null ? config.lfs : true

    def branch = env.BRANCH_NAME ?: 'main'

    def doFetchCheckout = {
        sh label: 'Quiet checkout', script: """
            set +x

            # Init repo if needed
            if [ ! -d .git ]; then
                git init --quiet
                git remote add origin "${url}"
            fi

            # Fetch with same refspecs as Git plugin, but quiet
            git fetch --quiet --force --prune origin ${refspec}

            # Checkout the exact commit
            COMMIT=\$(git rev-parse "origin/${branch}")
            git checkout --quiet -f \$COMMIT

            # Recreate local branch tracking the remote
            git branch -D "${branch}" 2>/dev/null || true
            git checkout --quiet -b "${branch}" \$COMMIT
        """

        if (lfs) {
            sh label: 'Git LFS pull', script: 'set +x; git lfs pull origin 2>/dev/null || true'
        }

        // Populate env vars that checkout scm would normally set
        env.GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
        env.GIT_URL = url
        env.GIT_BRANCH = "origin/${branch}"
    }

    if (credId) {
        // gitUsernamePassword sets up GIT_ASKPASS automatically, same as the Git plugin
        withCredentials([gitUsernamePassword(credentialsId: credId)]) {
            doFetchCheckout()
        }
    } else {
        // Rely on agent-level credentials (SSH key, credential helper, etc.)
        doFetchCheckout()
    }
}
