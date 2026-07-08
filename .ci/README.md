# ci-tools-lib

Various toolchain bits and pieces shared between projects — a shared CI/CD toolchain library for building, testing, scanning, and publishing containerized applications using Podman, Jenkins, and AWS ECR.

## Features

- **Container Build Orchestration** — Podman/Buildah rootless container builds with multi-architecture support (amd64, arm64) and a multi-arch manifest
- **Jenkins Shared Libraries** — Reusable, composable per-stage pipeline templates for Just-based projects
- **Forgejo SCM Integration** — Native change detection via API for PR and commit changesets (Forgejo is a Gitea fork sharing the `/api/v1` API, so a Gitea instance works too)
- **AWS ECR (public or private)** — Registry login, push, manifest management, and automated image lifecycle cleanup; public vs private auto-detected from the registry URL
- **Security Scanning** — Grype vulnerability scanning + betterleaks secret detection (source and image), with configurable severity thresholds and SARIF/JSON reporting surfaced via `recordIssues`
- **Semantic Versioning** — Automatic version computation from git tags with branch suffix support
- **Build Protection** — PR safety mechanism that overwrites build config files from the target branch
- **Builder Containers** — Optional isolated build environments (e.g. Rust toolchain with sccache, cargo-deny, cargo-auditable). One container is reused across all pipeline stages.
- **GitOps Writeback** — Post-build promotion: commit image tag/digest updates to a Forgejo-hosted manifests repo (direct push or PR-gated) so ArgoCD/Flux sync the change
- **Build Notifications** — Optional build-lifecycle messages (start / success / failure / aborted) via an apprise-api sidecar, fanning out to Slack / Matrix / Mattermost / Teams

## Quickstart

### 1. Add as a git submodule

```bash
git submodule add -b main https://git.zero-downtime.net/ZeroDownTime/ci-tools-lib.git .ci
```

The `-b main` records the tracked branch so [Renovate keeps `.ci/` updated](#maintenance). The URL can be any **mirror** of ci-tools-lib (e.g. your own Forgejo) — whatever you pass is stored in `.gitmodules` and is what Renovate then tracks; nothing in the library hardcodes the canonical URL.

Clone consumers with `git clone --recurse-submodules` (or run `git submodule update --init` after a plain clone), otherwise `.ci/` is empty and the `just` imports below fail. `git config --global submodule.recurse true` makes future pulls update it automatically.

### 2. Configure your project

Import the relevant `.just` modules in your `justfile`:

```just
import '.ci/container.just'
import '.ci/rust.just'
import '.ci/git.just'
```

### 3. Integrate with Jenkins

Add a `Jenkinsfile` using the shared library:

```groovy
@Library('ci-tools-lib') _

justContainer(
  imageName:   'my-app',
  registry:    'public.ecr.aws/<alias>',  // or '<account>.dkr.ecr.<region>.amazonaws.com'
  buildOnly:   ['src/.*', '.justfile'],
  needBuilder: true,
)
```

The Jenkins job must check out submodules so `.ci/` is populated before the pipeline runs — enable *Recursively update submodules* in the multibranch project's Git behaviours, or add an early `git submodule update --init`. (The `@Library` reference is fetched by the controller separately and needs no submodule.)

`registry` is required — set it explicitly per project. The library auto-detects public vs private ECR from the URL shape (`public.ecr.aws/...` vs `*.dkr.ecr.<region>.amazonaws.com`) and dispatches to the correct `aws ecr` / `aws ecr-public` API. Region for private is parsed from the hostname. Both the agent and dev workstation need ambient AWS credentials in scope (env vars, instance profile, etc.) — the library does no credential plumbing.

## Components

### Just — `.just` modules

All build logic lives in these modules so a developer reproduces full CI behaviour locally by running the same `just` recipes Jenkins runs.

| Module            | Key Recipes                                              |
|-------------------|----------------------------------------------------------|
| `container.just`  | `build`, `scan` (Grype + betterleaks), `push` (multi-arch manifest), `ecr-login`, `create-repo`, `rm-remote-untagged`, `clean`. Registry-touching recipes take the registry as their first positional arg; public vs private AWS ECR auto-detected from the URL. No default registry — every consumer declares it. |
| `rust.just`       | `prepare` (`cargo fetch --locked`), `lint` (clippy + cargo-deny), `build` (cargo auditable), `test`, `update-lock`, `cut-release`. Opt into an Alpine musl target with `CARGO_BUILD_MUSL`. |
| `python.just`     | uv-based: `prepare` (`uv sync --locked`), `lint` (flake8), `build` (`uv build`), `test` (pytest), `upload` (`uv publish`) |
| `git.just`        | Version computation from tags (`git describe`, `$TAG_MATCH`-aware), branch-suffixed `tag`, `arch` (`$ARCH`, default amd64), `cleanup-tags`, `ci-pull-upstream` |
| `builder.just`    | `update-builder` (build toolchain image), `use-builder <target>` (run a target inside the reused toolchain container; mounts repo root + sccache cache for Rust), `clean-builder` |
| `common.just`     | `scan-src` source secret scan; imported by the language modules |
| `gitops.just`     | `update`. Edits image tags / yq paths in a manifests repo, commits, pushes (with rebase-retry). Commit message comes from `$GITOPS_COMMIT_MESSAGE`. PR opening lives in `forgejo.groovy` (`forgejo.openPullRequest`). Updates spec is a JSON file so push-mode promotions reproduce locally. |

### Jenkins — Shared Library (`vars/`)

Thin glue only — each helper wraps Jenkins primitives around a `just` invocation; the real logic stays in the `.just` modules.

| Library                  | Purpose                                              |
|--------------------------|------------------------------------------------------|
| `justContainer.groovy`   | Entry point — the declarative pipeline composing the per-stage helpers |
| `container.groovy`       | Per-stage helpers (`changeset`, `prepare`, `lint`, `build`, `test`, `scan`, `push`, `clean`, `cleanBuilder`) invoked by `justContainer` |
| `forgejo.groovy`         | Forgejo API integration for change detection and PR open/reuse (Forgejo shares Gitea's `/api/v1` API; formerly `gitea.groovy`) |
| `notify.groovy`          | Optional build-lifecycle notifications via an apprise-api sidecar (see [Build notifications](#build-notifications)) |
| `protectBuild.groovy` | Overwrites CI files from the target branch during PR builds; optionally restores pinned submodules (e.g. `.ci`) too |
| `updateGitops.groovy` | GitOps writeback wrapper: commits yq-path updates to a Forgejo manifests repo (`push` or `pr` mode). Auto-picks `sshagent` vs. `gitUsernamePassword` from the repo URL scheme. See `examples/Jenkinsfile.gitops-{push,pr}.groovy`. |
| `seedMultiJob.groovy` | Job DSL seed for monorepos: discovers `*/Jenkinsfile` service subfolders and generates one Multibranch Pipeline job per service. Auto-targets the consuming repo (its own SCM). See [Monorepo: automated job-per-service setup](#monorepo-automated-job-per-service-setup). |

**Pipeline stages:** Changeset → Prepare → Lint → Build → Test → Scan → Push → Cleanup

`Changeset` is a minimal first stage that runs the forgejo change detection and sets the `SKIP` flag (no changed file matched `buildOnly`, and no force build) — every later stage, `Prepare` included, is gated on it, so the skip decision is made before any prep work runs. A `.ci` submodule bump triggers a build too: Forgejo reports the gitlink as the bare path `.ci`, and the matcher also tests `<path>/`, so a `'\\.ci/.*'` entry in `buildOnly` catches it.

`justContainer` declares a `FORCE_BUILD` boolean build parameter (default off). Tick it in "Build with Parameters" to bypass the `buildOnly` skip gate for a one-off rebuild without editing the Jenkinsfile. (The checkbox appears from the second build onward — Jenkins registers parameters retroactively.)

### Utilities

- **`ecr_lifecycle.py`** — Python utility (requires `boto3`) to manage ECR image lifecycle for public *and* private ECR: removes untagged images, prunes old dev-tagged images, keeps a configurable number of recent tagged images. Detects public vs private from the `--registry` URL.
- **`utils.sh`** — Bash helpers for semantic version bumping (`bumpVersion`) and git commit/tag/push automation (`addCommitTagPush`).
- **`Dockerfile.rust`** — Rust toolchain builder image (Alpine 3.24) with cargo, clippy, sccache (`RUSTC_WRAPPER`), cargo-auditable, cargo-deny, and just. Used by the `use-builder` flow.
- **`Dockerfile.python`** — Python toolchain builder image (Alpine 3.24, uv-based) for the `use-builder` flow.

## Monorepo layout

For a monorepo where each service has its own `.justfile`, `Jenkinsfile`, and `Dockerfile` under a subdirectory (e.g. `services/api-users/`), share one `.ci/` submodule at the repo root and pass per-service config:

```
repo/
├── .ci/                            # git submodule of ci-tools-lib
└── services/
    └── api-users/
        ├── Jenkinsfile
        ├── .justfile
        ├── Dockerfile
        └── pyproject.toml
```

**`services/api-users/.justfile`:**

```just
# Toolchain — flat-imported so `just lint`, `just prepare`, `just scan-src`,
# `just use-builder lint` etc. work. Pulls common.just, builder.just, git.just.
import '../../.ci/python.just'

# Container recipes namespaced — Jenkins glue calls `just container::build`.
mod container '../../.ci/container.just'
```

Per-service tag prefix (so `git describe` only sees this service's releases) is
set via the **`TAG_MATCH` env var**, not an in-justfile `export` — see the
Jenkinsfile `env:` below, and `git.just`'s Versioning notes for why. Locally:
`TAG_MATCH='api-users/v*.*.*' just …` or `just tag_match='api-users/v*.*.*' …`.

**`services/api-users/Jenkinsfile`:**

```groovy
@Library('ci-tools-lib') _

justContainer(
    workDir:     'services/api-users',
    imageName:   'api-users',
    registry:    '1234567890.dkr.ecr.us-east-1.amazonaws.com',  // or public.ecr.aws/<alias>
    buildOnly:   ['services/api-users/.*', '\\.ci/.*'],
    needBuilder: true,
    // Extra env (withEnv format) applied to the Prepare/Lint/Build/Test stages.
    // Per-service tag prefix goes here (read by git.just when computing git_tag):
    env: ['TAG_MATCH=api-users/v*.*.*'],
    // Static values only. Host-safe Rust opt-ins (read by use-builder inside the
    // Alpine builder): env: ['CARGO_BUILD_MUSL=true', 'ARCH=arm64'].
    // Optional build notifications via the apprise-api sidecar (see below).
    // notify: [key: 'team-platform'],   // events default to start/success/failure/aborted
)
```

`protect` defaults to `["${workDir}/.justfile", "${workDir}/Jenkinsfile"]`, so service-scoped build files are restored from the target branch on PR builds without needing to override it. (`.ci` is a submodule, which a plain file checkout can't restore — set `protectSubmodules: true` to additionally pin `.ci` to the target branch's commit on PR builds, at the cost of Renovate no longer validating `.ci`-bump PRs against the new pointer; left off, that integrity is a Jenkins controller-trust concern.) Tag releases as `api-users/v1.2.3`.

A Jenkins Multibranch project has a single *Script Path*, so one job can't serve many service subfolders. Give each service its own job either by hand (one Multibranch project per service, same repo, each *Script Path* set to `<service>/Jenkinsfile`) or automatically — see the next section.

## Monorepo: automated job-per-service setup

`seedMultiJob` (a Job DSL **seed**) generates one Multibranch Pipeline job per service from a single monorepo, so you don't click them together by hand. It **auto-targets the consuming repo** — the seed's own SCM is the repo, so `checkout scm` + `env.GIT_URL` (parsed by `forgejo.parseGitUrl`) yield server/owner/repo with nothing hardcoded. It globs `*/Jenkinsfile`, and for each match generates a Multibranch job whose only per-service difference is `scriptPath('<service>/Jenkinsfile')`. Re-running reconciles: a new service folder adds a job, a removed folder deletes its job.

Wire the seed one of two ways (both auto-target the repo):

```groovy
// The whole file — as the repo's root Jenkinsfile, or a 2-line wrapper (examples/seedJob.groovy)
@Library('ci-tools-lib') _
seedMultiJob()
```

1. **Root `Jenkinsfile`** under a Multibranch / Org-Folder job — auto-discovered like any other repo. The seed self-guards to run **only on the primary branch** (skips PRs and feature branches), so the per-service Jenkinsfiles in subfolders (which a folder scan ignores at root) get generated without the seed firing on every push.
2. **Dedicated Pipeline-script-from-SCM job** — bootstrap it as code with [`examples/jenkins.casc.yaml`](examples/jenkins.casc.yaml) (Configuration-as-Code), which points the seed at the consumer repo.

Behaviour and requirements:

- **Runs on the controller.** Pinned to `node('admin-dsl')` (an Exclusive-mode controller node) — it only mutates Jenkins job config and must not consume an agent executor. Keeps minimal build history (`numToKeep: 3`) since it's stateless.
- **Generated jobs land in a parallel plain folder `<org>-jobs/<repo>/<service>`.** A Gitea/Forgejo Organization Folder is *computed* and can't hold manually-created items, so the seed places jobs in a sibling plain folder (derived from `JOB_NAME`) rather than inside the org folder. Override with `seedMultiJob(jobFolder: '...')`.
- **Nested service layouts.** The default `discoveryGlob` is `*/Jenkinsfile` (one level). Widen it for the [Monorepo layout](#monorepo-layout) above — `seedMultiJob(discoveryGlob: 'services/*/Jenkinsfile')` — and the service's directory path is preserved as the Jenkins folder hierarchy (`<org>-jobs/<repo>/services/<svc>`), with the leaf as the job's display name. The repo-root seed `Jenkinsfile` and anything under `.ci/` are auto-excluded, so a recursive `**/Jenkinsfile` works too (prefer the explicit form).
- **The Gitea branch source is injected as raw XML** via a Job DSL `configure {}` block — `GiteaSCMSource` ships no `@Symbol`, so the dynamic `gitea {}` / `$class` DSL can't express it. Generated traits: branch + origin-PR + fork-PR (TrustContributors) discovery, tag discovery (releases arrive as tags), and **recursive submodules** (so `.ci` is checked out for service builds).
- **Credential.** `credentialsId` is the SCM *clone* credential the generated jobs use — often a PAT distinct from the REST-API one (e.g. ZDT passes `seedMultiJob(credentialsId: 'gitea-jenkins-pat')`); it defaults to `gitea-jenkins-password`.
- **Plugins:** Job DSL, Gitea, Pipeline Utility Steps. Job DSL **script security must be disabled** (the step runs `sandbox: false` on the trusted controller, avoiding per-generation script approval).

See [`examples/seedJob.groovy`](examples/seedJob.groovy) and [`examples/jenkins.casc.yaml`](examples/jenkins.casc.yaml).

## Build notifications

Optional build-lifecycle notifications (start / success / failure / aborted) are sent through an [apprise-api](https://github.com/caronc/apprise-api) sidecar running next to the Jenkins controller. `justContainer` POSTs a single JSON event; apprise-api fans out to the configured chat targets (Slack, Matrix, Mattermost, Teams, ...). Off unless `notify` is set — existing consumers are unaffected.

Destinations and their secrets live in apprise-api **config keys**, never in this repo: register e.g. `slack://…`/`matrix://…` URLs under a key (`team-platform`) on the sidecar, then reference the key from the Jenkinsfile. If `key` is omitted (and no `urls` are given), the module falls back to apprise-api's conventional `default` key — so a single shared `default` config requires no per-Jenkinsfile `key` at all.

```groovy
justContainer(
    // ...
    notify: [
        // key:        'team-platform',                // apprise-api config key (defaults to 'default' when omitted)
        // urls:       ['slack://T/B/xxx'],             // stateless alternative (destinations in-repo)
        // events:     ['start', 'success', 'failure', 'aborted'],  // this is the default set
        tag:           'ci',                            // optional apprise tag filter
        // url:        'http://apprise-api:8000',       // optional; defaults to env.APPRISE_API_URL
        // credentialsId: 'apprise-token',              // optional Secret Text -> 'Authorization: Bearer <token>'
        // notifySkipped: true,                         // also notify SKIP (no-change) builds
        // messages:   [failure: { "build broke: ${env.BUILD_URL}" }],  // optional per-event body closures
    ],
)
```

- **Endpoint** is shared infra, so set `APPRISE_API_URL` once on the controller (global env); `notify.url` overrides per-job.
- **Destinations** resolve in this order: an explicit `key` → `/notify/<key>`; else inline `urls` → stateless `/notify`; else the `default` key → `/notify/default`. Pre-register that `default` config on the sidecar to drive notifications from `notify: [events: [...]]` alone.
- **Events** map from the build result: `SUCCESS→success`, `FAILURE→failure`, `UNSTABLE→unstable`, `ABORTED`/`NOT_BUILT→aborted`, plus `start`. All five fire by default (`['start','success','failure','aborted']`); set `events` to narrow the set. The apprise notification `type` (`info`/`success`/`warning`/`failure`) drives per-platform colour automatically.
- **Aborted builds** fire from `post { always }` like any other end event. A UI abort interrupts the in-flight notification step once, so the send is retried a single time to survive the abort — a hard/double-kill that tears the executor down may still skip it.
- **SKIP builds** (no source changes) are silent unless `notifySkipped: true` (governs start and end symmetrically).
- **Title** reads like a sentence with a leading status emoji and, on end events, a build-status transition vs. the previous run — e.g. `🚀 Jenkins build of api-users/main started`, `✅ Jenkins build of api-users/main finished successfully (Fixed)`, `❌ … failed (Still failing)`.
- **Body** defaults to a one-line summary: a PR/branch ref (PR builds link to `CHANGE_URL`; branch builds link to the forgejo branch page), the short commit SHA (linked to the forgejo commit page), and a linked Jenkins `build <number>` followed by the trigger cause (`triggered by user …`) on start events, or the duration (`took …`) on end events. All git links are derived in-process from `GIT_URL` (via `forgejo.parseGitUrl`) — no remote call. Override any event's body with a closure under `messages` (resolved lazily so `env`/`currentBuild` are populated).
- A notification problem (sidecar down, bad key) is logged and **never fails the build**.

## GitOps writeback

Promote a freshly built image into a Forgejo-hosted manifests repo so ArgoCD/Flux picks it up. The image tag is captured from `container.push(config)`'s return value (the actual `git_tag` published — e.g. `v1.2.3` on a tagged commit) and threaded into the Promote stage:

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

PR-gated mode adds `mode: 'pr'`, `tokenCredentialsId:` (Forgejo API token), `prBranch:`, `prTitle:`, `prBody:`. Returns `[sha, branch, prUrl]`. The PR branch is reused on re-runs (idempotent: existing open PR URL is returned). See `examples/Jenkinsfile.gitops-push.groovy` and `examples/Jenkinsfile.gitops-pr.groovy` for full pipelines.

Reproduce locally with the same recipes Jenkins runs:

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

For ergonomics, define the registry once in your project's root `.justfile` and add convenience wrappers:

```just
registry := "public.ecr.aws/<alias>"          # or "<account>.dkr.ecr.<region>.amazonaws.com"

mod container '.ci/container.just'
import '.ci/python.just'                       # or rust.just

# Convenience wrappers — pass the registry through to module recipes
push image="":
  just container::push {{ registry }} {{ image }}

ecr-login:
  just container::ecr-login {{ registry }}

create-repo image="":
  just container::create-repo {{ registry }} {{ image }}
```

`build`, `scan`, and `clean` recipes don't take a registry, so they remain reachable as `just container::build` etc. without any wrapping. The Jenkins glue passes the registry directly from the `registry:` config field — consumers don't need wrappers for CI.

## Maintenance

`.ci/` is a git submodule tracking `main`. Let Renovate keep it current automatically — enable its built-in submodule manager in the consumer's `renovate.json`:

```json
{
  "extends": ["config:recommended"],
  "git-submodules": { "enabled": true }
}
```

Renovate then opens a PR in each consumer whenever `ci-tools-lib` `main` advances. Because the submodule is a separate repo boundary, Renovate does **not** scan the dependencies *inside* `.ci/` (the toolchain Dockerfiles etc.) — those are maintained upstream, so no per-consumer noise.

To update by hand instead, run `just ci-pull-upstream` (or `git submodule update --remote --merge .ci`) and commit the bumped pointer.

Ready-to-copy consumer config is in [`examples/renovate.json`](examples/renovate.json). Projects still on the old `git subtree` layout can convert in one shot with [`examples/migrate-to-submodule.sh`](examples/migrate-to-submodule.sh) (run from the consumer repo root; it stages the swap for review).

**Mirroring.** To consume from your own mirror instead of the canonical URL, just point the submodule at it — `git submodule add -b main <your-mirror-url> .ci`, or run the migration script with `CI_TOOLS_URL` (and optionally `CI_TOOLS_BRANCH`) set. The source lives entirely in the consumer's `.gitmodules`; Renovate tracks whatever is there.

## Renovate

Run renovate locally to test custom config:

```bash
LOG_LEVEL=debug ~/node_modules/renovate/dist/renovate.js --platform local --dry-run
```

## License

[GNU AGPL v3](LICENSE)
