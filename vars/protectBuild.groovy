// PR-only build protection: overwrite CI files — and optionally restore pinned
// submodules — from the target branch so a pull request can't alter the CI
// behaviour that builds it. No-op on non-PR builds.
//
// Args (Map):
//   files       paths restored via `git checkout origin/<target> -- …`
//               (default ['Makefile', '.justfile']).
//   submodules  submodule paths whose gitlink + .gitmodules entry are restored
//               from the target branch and re-synced (default []). Opt-in: a PR
//               can otherwise run modified recipes from a submodule (e.g. `.ci`)
//               by bumping its gitlink or pointing .gitmodules at a fork. Plain
//               file protection can't cover this — the parent repo tracks only
//               the gitlink, not the submodule's files. Enabling it also stops
//               Renovate's submodule-bump PRs from validating the new pointer
//               (they build against the target's pin instead).
def call(Map args = [:]) {
    if (!env.CHANGE_ID) {
        echo "Not a PR build, skipping build protection"
        return
    }

    def files      = args.files      ?: ['Makefile', '.justfile']
    def submodules = args.submodules ?: []

    sh "git fetch origin ${env.CHANGE_TARGET}"

    if (files) {
        sh "git checkout origin/${env.CHANGE_TARGET} -- ${files.join(' ')}"
    }

    if (submodules) {
        // git checkout only rewrites the index gitlink + .gitmodules; the PR's
        // already-checked-out submodule working tree stays until sync + update.
        sh "git checkout origin/${env.CHANGE_TARGET} -- .gitmodules ${submodules.join(' ')}"
        for (path in submodules) {
            sh "git submodule sync -- '${path}'"
            sh "git submodule update --init -f '${path}'"
        }
    }
}
