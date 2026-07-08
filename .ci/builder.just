set allow-duplicate-variables
set dotenv-load

toolchain := "rust"

update-builder:
  podman build -t local-{{ toolchain }}-builder -f {{ source_directory() }}/Dockerfile.{{ toolchain }} {{ source_directory() }}

# runs available just targets inside the builder.
# Reuses one working container per pipeline (named via $BUILD_TAG when set) so
# toolchain caches survive across stages; caller invokes `clean-builder` at end.
# Mounts the repo root so relative imports like `../../.ci/python.just` resolve,
# then cd's into the caller's path within the repo.
[no-exit-message]
use-builder +target:
  #!/usr/bin/env bash
  set -e
  root=$(git rev-parse --show-toplevel)
  cwd=$(pwd)
  case "$cwd" in
    "$root") rel="." ;;
    "$root/"*) rel="${cwd#"$root/"}" ;;
    *) echo "cwd $cwd not under repo root $root" >&2; exit 1 ;;
  esac
  build_id=$(echo "${BUILD_TAG:-local}" | tr -c 'A-Za-z0-9._-' '-')
  name="local-{{ toolchain }}-builder-${build_id}"
  builder=$(buildah containers --json 2>/dev/null | jq -r --arg n "$name" '.[]? | select(.containername == $n) | .id')
  [ -z "$builder" -o "$builder" == "null" ] && builder=$(buildah from --name "$name" localhost/local-{{ toolchain }}-builder:latest)
  mounts=(-v "$root:/app")
  if [ "{{ toolchain }}" = "rust" ]; then
    sccache_cache="${SCCACHE_DIR:-$HOME/.cache/sccache}"
    mkdir -p "$sccache_cache"
    mounts+=(-v "$sccache_cache:/root/.cache/sccache")
    # Pin the Alpine musl target triple *inside the builder only*, so artifacts
    # land in target/<triple>/ without affecting cargo on a non-Alpine dev host
    # (plain `just build`). Opt in per-project with `export CARGO_BUILD_MUSL := "true"`
    # (or env CARGO_BUILD_MUSL=true); the triple follows ARCH. An explicit
    # CARGO_BUILD_TARGET in the env takes precedence.
    if [ -z "${CARGO_BUILD_TARGET:-}" ] && [ -n "${CARGO_BUILD_MUSL:-}" ]; then
      case "${ARCH:-amd64}" in
        arm64) CARGO_BUILD_TARGET="aarch64-alpine-linux-musl" ;;
        *)     CARGO_BUILD_TARGET="x86_64-alpine-linux-musl" ;;
      esac
    fi
    [ -n "${CARGO_BUILD_TARGET:-}" ] && mounts+=(-e "CARGO_BUILD_TARGET=$CARGO_BUILD_TARGET")
  fi
  buildah config --workingdir "/app/$rel" $builder
  buildah run "${mounts[@]}" $builder -- just {{ target }}

# Remove the per-pipeline builder container. Safe to call when none exists.
clean-builder:
  #!/usr/bin/env bash
  build_id=$(echo "${BUILD_TAG:-local}" | tr -c 'A-Za-z0-9._-' '-')
  buildah rm "local-{{ toolchain }}-builder-${build_id}" 2>/dev/null || true
