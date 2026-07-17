# ci-tools-lib

Shared CI/CD toolchain for building, testing, scanning, and publishing containerized applications with Podman, Jenkins, and AWS ECR. Consumed as a `.ci/` git submodule plus a Jenkins shared library (`@Library('ci-tools-lib')`).

## Features

- **Container builds** — rootless Podman/Buildah, multi-arch (amd64/arm64) manifest
- **Jenkins shared library** — composable per-stage pipeline for Just-based projects
- **Forgejo/Gitea SCM** — change detection via `/api/v1` for PR and commit changesets
- **AWS ECR (public or private)** — login, push, manifest management, lifecycle cleanup
- **Security scanning** — Grype (vulnerabilities) + betterleaks (secrets), source and image
- **Semantic versioning** — from git tags, with branch suffix
- **Build protection** — overwrites build config files from the target branch on PRs
- **Builder containers** — optional toolchain images (e.g. Rust with sccache), reused across stages
- **GitOps writeback** — commit image tags to a manifests repo (direct push or PR-gated)
- **Build notifications** — start / success / failure / aborted via an apprise-api sidecar

## Quickstart

### 1. Add as a git submodule

```bash
git submodule add -b main https://git.zero-downtime.net/ZeroDownTime/ci-tools-lib.git .ci
```

Clone consumers with `git clone --recurse-submodules` (or run `git submodule update --init` after a plain clone). The URL can be any mirror; it's stored in `.gitmodules`.

### 2. Import the `.just` modules in your `justfile`

```just
import '.ci/container.just'
import '.ci/rust.just'
import '.ci/git.just'
```

### 3. Add a `Jenkinsfile`

```groovy
@Library('ci-tools-lib') _

justContainer(
  imageName:   'my-app',
  registry:    'public.ecr.aws/<alias>',  // or '<account>.dkr.ecr.<region>.amazonaws.com'
  buildOnly:   ['src/.*', '.justfile'],
  needBuilder: true,
)
```

`registry` is required — the `registry:` config field, or the `REGISTRY` env var. The Jenkins job must check out submodules so `.ci/` is populated — enable *Recursively update submodules* in the multibranch project's Git behaviours, or add an early `git submodule update --init`. Public vs private ECR is auto-detected from the URL; AWS credentials must be ambient (env vars, instance profile).

## Components

### Just — `.just` modules

| Module            | Key recipes                                              |
|-------------------|----------------------------------------------------------|
| `container.just`  | `build`, `scan` (Grype + betterleaks), `push` (multi-arch manifest), `ecr-login`, `create-repo`, `rm-remote-untagged`, `clean`. Registry-touching recipes take the registry as their first positional arg, defaulting to the `REGISTRY` env var. Image name defaults to `IMAGE_NAME` (env), else the git repo name. |
| `rust.just`       | `prepare` (`cargo fetch --locked`), `lint` (clippy + cargo-deny), `build` (cargo auditable), `test`, `update-lock`, `cut-release`. Opt into an Alpine musl target with `CARGO_BUILD_MUSL`. |
| `python.just`     | uv-based: `prepare` (`uv sync --locked`), `lint` (flake8), `build` (`uv build`), `test` (pytest), `upload` (`uv publish`) |
| `git.just`        | Version from tags (`$TAG_MATCH`-aware), branch-suffixed `tag`, `arch` (`$ARCH`, default amd64), `cleanup-tags`, `ci-pull-upstream` |
| `builder.just`    | `update-builder`, `use-builder <target>` (run a target inside the reused toolchain container), `clean-builder` |
| `common.just`     | `scan-src` source secret scan; imported by the language modules |
| `gitops.just`     | `update` — edit image tags / yq paths in a manifests repo, commit, push (rebase-retry) |

### Jenkins — shared library (`vars/`)

| Library                  | Purpose                                              |
|--------------------------|------------------------------------------------------|
| `justContainer.groovy`   | Entry point — declarative pipeline composing the per-stage helpers |
| `container.groovy`       | Per-stage helpers (`changeset`, `prepare`, `lint`, `build`, `test`, `scan`, `push`, `clean`, `cleanBuilder`) |
| `forgejo.groovy`         | Forgejo/Gitea `/api/v1` change detection and PR open/reuse |
| `notify.groovy`          | Optional build notifications via apprise-api (see [Build notifications](#build-notifications)) |
| `protectBuild.groovy`    | Overwrites CI files from the target branch on PR builds; optional submodule pin |
| `updateGitops.groovy`    | GitOps writeback (`push` or `pr`). See `examples/Jenkinsfile.gitops-{push,pr}.groovy` |
| `seedMultiJob.groovy`    | Job DSL seed — one Multibranch job per monorepo service (see [below](#monorepo-automated-job-per-service-setup)) |

**Pipeline stages:** Changeset → Prepare → Lint → Build → Test → Scan → Push → Cleanup

`buildOnly` gates the build; include `'\\.ci/.*'` to rebuild on a `.ci` submodule bump. Set the `FORCE_BUILD` build parameter (in "Build with Parameters") to bypass the gate for a one-off rebuild.

Skipped builds (no changed file matched `buildOnly`) are pruned from job history by default, so a monorepo's sibling jobs don't clutter it on every push. Jenkins can't delete a still-running build, so each build deletes the finished SKIP builds before it — the most recent SKIP lingers until the next run. Set `discardSkipped: false` to keep them. Pruning needs a one-time admin approval of `RunWrapper.getRawBuild` / `Run.delete` in *In-process Script Approval* (until then it's a logged no-op — builds never fail over it).

### Utilities

- **`ecr_lifecycle.py`** — (requires `boto3`) prune ECR images: removes untagged, prunes old dev-tagged, keeps recent tagged. Public vs private detected from `--registry`.
- **`utils.sh`** — Bash helpers: `bumpVersion`, `addCommitTagPush`.
- **`Dockerfile.rust`** — Rust toolchain image (Alpine 3.24): cargo, clippy, sccache, cargo-auditable, cargo-deny, just.
- **`Dockerfile.python`** — Python toolchain image (Alpine 3.24, uv-based).

## Monorepo layout

Each service has its own `.justfile`, `Jenkinsfile`, and `Dockerfile` under a subdirectory, sharing one `.ci/` submodule at the repo root:

```
repo/
├── .ci/                            # git submodule of ci-tools-lib
└── services/
    └── api-users/
        ├── Jenkinsfile
        ├── .justfile
        ├── .env                    # per-service IMAGE_NAME + REGISTRY (loaded via set dotenv-load)
        ├── Dockerfile
        └── pyproject.toml
```

**`services/api-users/.justfile`:**

```just
set dotenv-load                     # load .env before the modules evaluate their variables

import '../../.ci/python.just'      # flat import: just lint / prepare / scan-src / use-builder …
mod container '../../.ci/container.just'
```

**`services/api-users/.env`:**

```
IMAGE_NAME=api-users
REGISTRY=1234567890.dkr.ecr.us-east-1.amazonaws.com
```

**`services/api-users/Jenkinsfile`:**

```groovy
@Library('ci-tools-lib') _

justContainer(
    workDir:     'services/api-users',
    imageName:   'api-users',
    registry:    '1234567890.dkr.ecr.us-east-1.amazonaws.com',  // or public.ecr.aws/<alias>
    buildOnly:   ['services/api-users/.*', '\\.ci/.*'],
    needBuilder: true,
    env: ['TAG_MATCH=api-users/v*.*.*'],
    // Host-safe Rust opt-ins:  env: ['CARGO_BUILD_MUSL=true', 'ARCH=arm64']
    // notify: [key: 'team-platform']
)
```

Per-service settings:

- **Image name** — set `IMAGE_NAME` (via `set dotenv-load` + `.env` as shown, a launch env var `IMAGE_NAME=api-users just container::build`, or the Jenkins `imageName` field). A plain `image_name :=` in the `.justfile` does not cross the `mod` boundary.
- **Registry** — same pattern via `REGISTRY` (`.env` / launch env), or the Jenkins `registry:` field. Empty when unset — the registry-touching recipes then fail.
- **Tag prefix** — set `TAG_MATCH`: Jenkins `env: ['TAG_MATCH=api-users/v*.*.*']`, or locally `TAG_MATCH='api-users/v*.*.*' just …` / `just tag_match='api-users/v*.*.*' …`. Tag releases as `api-users/v1.2.3`.
- **Build-file protection** — `protect` defaults to the service `.justfile` + `Jenkinsfile`; set `protectSubmodules: true` to also restore the `.ci` pointer from the target branch on PR builds.
- **Nesting depth** — services can sit at any depth (`services/api-users` above is two levels). The build/version machinery is depth-agnostic; just match the config to the depth: the import `../` count (`import '../../.ci/…'` for two levels, `../../../.ci/…` for three), and the full path in `workDir` (`a/b/c`) and `buildOnly` (`a/b/c/.*`).

Each service needs its own Jenkins job (Multibranch *Script Path* `<service>/Jenkinsfile`) — create them by hand or with `seedMultiJob` (next section).

## Monorepo: automated job-per-service setup

`seedMultiJob` generates one Multibranch Pipeline job per service from a monorepo, auto-targeting the consuming repo (its own SCM). It globs `*/Jenkinsfile` and generates a job per match; re-running reconciles adds/removals.

Wire it as the repo's root `Jenkinsfile` (Multibranch / Org-Folder job — self-guards to the primary branch) or a dedicated Pipeline-script-from-SCM job (bootstrap via [`examples/jenkins.casc.yaml`](examples/jenkins.casc.yaml)):

```groovy
@Library('ci-tools-lib') _
seedMultiJob()
```

Options (all optional):

- `jobFolder` — Jenkins folder for the generated jobs (default `<org>-jobs/<repo>`, derived from `JOB_NAME`)
- `discoveryGlob` — service glob (default `*/Jenkinsfile`, **one level only**). Widen for deeper layouts: `'services/*/Jenkinsfile'` (fixed depth), or `'**/Jenkinsfile'` (any depth — auto-excludes the root seed `Jenkinsfile` and `.ci/`). The service's directory path becomes the Jenkins folder hierarchy, with the leaf as the job display name.
- `credentialsId` — SCM clone credential (default `gitea-jenkins-password`; ZDT uses `gitea-jenkins-pat`)

Runs on `node('admin-dsl')` (the controller). Requires plugins: Job DSL, Gitea, Pipeline Utility Steps, with Job DSL script security disabled. See [`examples/seedJob.groovy`](examples/seedJob.groovy) and [`examples/jenkins.casc.yaml`](examples/jenkins.casc.yaml).

## Build notifications

Build-lifecycle notifications go through an [apprise-api](https://github.com/caronc/apprise-api) sidecar. Off unless `notify` is set. Destinations live in apprise-api config keys, referenced by `key` (defaults to the `default` key).

```groovy
justContainer(
    // ...
    notify: [
        // key:           'team-platform',              // apprise-api config key (defaults to 'default')
        // urls:          ['slack://T/B/xxx'],          // stateless alternative
        // events:        ['start', 'success', 'failure', 'aborted'],  // default set
        tag:              'ci',                          // optional apprise tag filter
        // url:           'http://apprise-api:8000',     // defaults to env.APPRISE_API_URL
        // credentialsId: 'apprise-token',              // Secret Text -> 'Authorization: Bearer <token>'
        // notifySkipped: true,                          // also notify SKIP (no-change) builds
        // messages:      [failure: { "build broke: ${env.BUILD_URL}" }],  // per-event body closures
    ],
)
```

- Set `APPRISE_API_URL` once on the controller; `notify.url` overrides per-job.
- Destinations resolve as: explicit `key` → `/notify/<key>`; else `urls` → `/notify`; else `default` key → `/notify/default`.
- Events: `SUCCESS→success`, `FAILURE→failure`, `UNSTABLE→unstable`, `ABORTED`/`NOT_BUILT→aborted`, plus `start`. Set `events` to narrow the set.
- SKIP builds are silent unless `notifySkipped: true`.
- A notification failure never fails the build.

## GitOps writeback

Promote a built image into a Forgejo-hosted manifests repo. The tag is captured from `container.push(config)` and threaded into the Promote stage:

```groovy
@Library('ci-tools-lib') _

def config   = [imageName: 'payments', registry: '...', /* ... */]
def imageTag                                   // captured in Push, consumed in Promote

pipeline {
    // ... agent, Prepare/Lint/Build/Test/Scan stages calling container.<stage>(config) ...

    stage('Push')   { steps { script { imageTag = container.push(config) } } }

    stage('Promote') {
        steps { script {
            updateGitops(
                repo:          'git@git.zero-downtime.net:zdt/infra.git',  // or https://...
                branch:        'main',
                credentialsId: 'infra-repo-deploy-key',                    // SSH key, or userpass for HTTPS
                updates: [
                    'apps/payments/values.yaml': [
                        '.image.tag': imageTag,
                    ],
                ],
            )
        } }
    }
}
```

PR-gated mode adds `mode: 'pr'`, `tokenCredentialsId:` (Forgejo API token), `prBranch:`, `prTitle:`, `prBody:`; returns `[sha, branch, prUrl]`. See `examples/Jenkinsfile.gitops-push.groovy` and `examples/Jenkinsfile.gitops-pr.groovy`.

Reproduce locally:

```bash
echo '{"apps/payments/values.yaml":{".image.tag":"v1.2.3"}}' > /tmp/u.json
just gitops::update git@git.zero-downtime.net:zdt/infra.git main /tmp/u.json
```

The consumer's root justfile must import the module: `mod gitops '.ci/gitops.just'`.

## Local dev

Recipes that touch the registry take it as their first positional argument:

```bash
just container::build my-app                                          # registry not needed
just container::ecr-login public.ecr.aws/<alias>
just container::push public.ecr.aws/<alias> my-app
just container::create-repo public.ecr.aws/<alias> my-app
```

Define the registry once and add convenience wrappers:

```just
registry := "public.ecr.aws/<alias>"          # or "<account>.dkr.ecr.<region>.amazonaws.com"

mod container '.ci/container.just'
import '.ci/python.just'                       # or rust.just

push image="":
  just container::push {{ registry }} {{ image }}

ecr-login:
  just container::ecr-login {{ registry }}

create-repo image="":
  just container::create-repo {{ registry }} {{ image }}
```

`build`, `scan`, and `clean` take no registry. The registry and image-name positionals are optional — they default to the `REGISTRY` and `IMAGE_NAME` env vars (image falls back to the git repo name). Set them via a launch env var or `set dotenv-load` + `.env` (see [Monorepo layout](#monorepo-layout)).

## Maintenance

`.ci/` tracks `main`. Let Renovate keep it current — enable its submodule manager:

```json
{
  "extends": ["config:recommended"],
  "git-submodules": { "enabled": true }
}
```

To update by hand: `just ci-pull-upstream` (or `git submodule update --remote --merge .ci`) and commit the bumped pointer.

Ready-to-copy config is in [`examples/renovate.json`](examples/renovate.json). Convert from the old `git subtree` layout with [`examples/migrate-to-submodule.sh`](examples/migrate-to-submodule.sh). To use a mirror, point the submodule at it (or run the migration with `CI_TOOLS_URL` / `CI_TOOLS_BRANCH` set).

## Renovate

Test custom config locally:

```bash
LOG_LEVEL=debug ~/node_modules/renovate/dist/renovate.js --platform local --dry-run
```

## License

[GNU AGPL v3](LICENSE)
