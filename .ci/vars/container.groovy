// Container build stages — composed by justContainer.groovy.
// Each method is invoked as `container.<stage>(config)`.

// Changeset stage: forgejo changeset + buildOnly/forceBuild gate. Sets
// currentBuild.description = 'SKIP' (which gates every downstream stage,
// including Prepare) when no changed file matches buildOnly and forceBuild is
// not set. A tagged release (HEAD exactly on a release tag) always builds,
// regardless of the changeset — releases must never be skipped. Minimal by
// design — the heavy prep work lives in prepare(), so the SKIP decision is
// made before any of it runs.
def changeset(Map config = [:]) {
    def debug      = config.debug      ?: false
    def workDir    = config.workDir    ?: '.'
    def buildOnly  = config.buildOnly  ?: ['.*']
    def forceBuild = config.forceBuild != null ? config.forceBuild : (config.force_build ?: false)
    def buildEnv   = config.env        ?: []

    // buildEnv (e.g. TAG_MATCH) must wrap every just call that computes git_tag/
    // is_release so the tag matches across stages — see push/scan/clean too.
    def isRelease = false
    dir(workDir) {
        withEnv(buildEnv) {
            isRelease = sh(returnStdout: true, script: 'just container::_is-release').trim() == 'true'
        }
    }
    if (isRelease) {
        echo "HEAD is on a release tag — building regardless of changeset."
        return
    }

    def files = forgejo.getChangeset(debug: debug)

    if (!forceBuild && !forgejo.pathsChanged(files: files, patterns: buildOnly, debug: debug)) {
        echo "No changed files matching any of: ${buildOnly.join(', ')}. Skipping downstream stages."
        currentBuild.description = 'SKIP'
    }
}

// Prepare stage: protect build files, create tmpDir, build the toolchain image
// (if needBuilder) and run the optional `just prepare`. Gated on the SKIP flag
// set by changeset(), so it only runs for real builds.
def prepare(Map config = [:]) {
    def workDir     = config.workDir     ?: '.'
    def tmpDir      = config.tmpDir      ?: '_tmp'
    def needBuilder = config.needBuilder ?: false
    def justfilePath    = workDir == '.' ? '.justfile' : "${workDir}/.justfile"
    def jenkinsfilePath = workDir == '.' ? 'Jenkinsfile' : "${workDir}/Jenkinsfile"
    def protect     = config.protect     ?: [justfilePath, jenkinsfilePath]
    def buildEnv    = config.env         ?: []
    // Opt-in submodule pointer protection (true → ['.ci']); see vars/protectBuild.groovy.
    def submodules  = (config.protectSubmodules == true) ? ['.ci']
                    : (config.protectSubmodules ?: [])

    protectBuild(files: protect, submodules: submodules)

    dir(workDir) {
        withEnv(buildEnv) {
            sh "mkdir -p '${tmpDir}'"
            if (needBuilder) {
                sh "just update-builder"
                sh "if just --summary | grep -q prepare; then just use-builder prepare; fi"
            } else {
                sh "if just --summary | grep -q prepare; then just prepare; fi"
            }
        }
    }
}

// Lint stage: `just scan-src` source secrets scan + `just lint`
def lint(Map config = [:]) {
    def workDir     = config.workDir     ?: '.'
    def tmpDir      = config.tmpDir      ?: '_tmp'
    def needBuilder = config.needBuilder ?: false
    def scanFail    = config.scanFail != null ? config.scanFail : true
    def buildEnv    = config.env         ?: []

    dir(workDir) {
        withEnv(["BETTERLEAKS_SRC_FILE=${tmpDir}/betterleaks-src-report.json"]) {
            sh "if just --summary | grep -q scan-src; then just scan-src; fi"
        }

        recordIssues(
            enabledForFailure: true,
            sourceCodeRetention: 'NEVER',
            skipPublishingChecks: true,
            quiet: true,
            skipBlames: true,
            qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', criticality: scanFail ? 'FAILURE' : 'NOTE']],
            tools: [
                sarif(pattern: "${tmpDir}/betterleaks-src-report.json", id: 'source-leaks', name: 'Source Leaks')
            ]
        )

        withEnv(buildEnv) {
            if (needBuilder) {
                sh "if just --summary | grep -q fmt; then just use-builder fmt release; fi"
                sh "if just --summary | grep -q lint; then just use-builder lint release; fi"
            } else {
                sh "if just --summary | grep -q fmt; then just fmt release; fi"
                sh "if just --summary | grep -q lint; then just lint release; fi"
            }
        }
    }
}

// Build stage: `just container::build`. The buildOnly/forceBuild gate runs
// in `prepare`; if it short-circuits, this stage is skipped via the SKIP flag.
def build(Map config = [:]) {
    def workDir     = config.workDir     ?: '.'
    def imageName   = config.imageName   ?: ''
    def needBuilder = config.needBuilder ?: false
    def buildEnv    = config.env         ?: []

    def imageArg = imageName ? " '${imageName}'" : ''
    String tag

    dir(workDir) {
        withEnv(buildEnv) {
            if (needBuilder) {
                sh "just use-builder build release"
            }
            sh "just container::build${imageArg}"
            tag = sh(returnStdout: true, script: 'just container::_print-tag').trim()
        }
    }
    return tag
}

// Test stage: optional `just test`, run if the recipe is defined
def test(Map config = [:]) {
    def workDir     = config.workDir     ?: '.'
    def needBuilder = config.needBuilder ?: false
    def buildEnv    = config.env         ?: []

    dir(workDir) {
        withEnv(buildEnv) {
            if (needBuilder) {
                sh "if just --summary | grep -q test; then just use-builder test release; fi"
            } else {
                sh "if just --summary | grep -q test; then just test release; fi"
            }
        }
    }
}

// Scan stage: `just container::scan` + grype/betterleaks recordIssues
def scan(Map config = [:]) {
    def workDir   = config.workDir   ?: '.'
    def tmpDir    = config.tmpDir    ?: '_tmp'
    def imageName = config.imageName ?: ''
    def scanFail  = config.scanFail != null ? config.scanFail : true
    def buildEnv  = config.env       ?: []
    def imageArg  = imageName ? " '${imageName}'" : ''

    dir(workDir) {
        withEnv(buildEnv + [
            "GRYPE_LOG_QUIET=true",
            "GRYPE_OUTPUT=json",
            "GRYPE_FILE=${tmpDir}/grype-report.json",
            "BETTERLEAKS_FILE=${tmpDir}/betterleaks-image-report.json",
        ]) {
            sh "just container::scan '${tmpDir}'${imageArg}"
        }

        recordIssues(
            enabledForFailure: true,
            sourceCodeRetention: 'NEVER',
            skipPublishingChecks: true,
            quiet: true,
            skipBlames: true,
            qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', criticality: scanFail ? 'FAILURE' : 'NOTE']],
            tools: [
                grype(pattern: "${tmpDir}/grype-report.json")
            ]
        )

        recordIssues(
            enabledForFailure: true,
            sourceCodeRetention: 'NEVER',
            skipPublishingChecks: true,
            quiet: true,
            skipBlames: true,
            qualityGates: [[threshold: 1, type: 'TOTAL_ERROR', criticality: scanFail ? 'FAILURE' : 'NOTE']],
            tools: [
                sarif(pattern: "${tmpDir}/betterleaks-image-report.json", id: 'image-leaks', name: 'Image Leaks')
            ]
        )
    }
}

// Push stage: `just container::push <registry> [imageName]` + rm-remote-untagged.
// Returns the pushed tag (the value of git_tag the push recipe used).
def push(Map config = [:]) {
    def workDir   = config.workDir   ?: '.'
    def imageName = config.imageName ?: ''
    def registry  = config.registry  ?: ''

    if (!registry) {
        error("'registry' is required in the justContainer config (e.g. 'public.ecr.aws/<alias>' or '<account>.dkr.ecr.<region>.amazonaws.com')")
    }

    def imageArg = imageName ? " '${imageName}'" : ''
    def buildEnv = config.env ?: []
    String tag

    dir(workDir) {
        withEnv(buildEnv) {
            sh "just container::push '${registry}'${imageArg}"
            sh "just container::rm-remote-untagged '${registry}'${imageArg}"
            tag = sh(returnStdout: true, script: 'just container::_print-tag').trim()
        }
    }
    return tag
}

// Cleanup stage: `just container::clean`
def clean(Map config = [:]) {
    def workDir   = config.workDir   ?: '.'
    def imageName = config.imageName ?: ''
    def buildEnv  = config.env       ?: []
    def imageArg  = imageName ? " '${imageName}'" : ''

    dir(workDir) {
        withEnv(buildEnv) {
            sh "just container::clean${imageArg}"
        }
    }
}

// Post-pipeline: remove the reusable builder container created by `use-builder`.
// Called from `post.cleanup` so the container is torn down even on abort/failure.
def cleanBuilder(Map config = [:]) {
    def workDir     = config.workDir     ?: '.'
    def needBuilder = config.needBuilder ?: false
    if (!needBuilder) return

    dir(workDir) {
        sh "just clean-builder"
    }
}

return this
