import 'builder.just'
import 'common.just'
import 'git.just'

prepare:
  cargo fetch --locked

# requires 1.45 [arg('target', pattern='(release)?')]
lint target="":
  #!/usr/bin/env sh
  set -e
  if [ "{{ target }}" == "release" ]; then
    cargo clippy --workspace --locked --all-targets --release -- -D warnings
  else
    cargo clippy --workspace --locked --all-targets -- -D warnings
  fi
  cargo deny check -s

# requires 1.45 [arg('target', pattern='(release)?')]
fmt target="":
  #!/usr/bin/env sh
  set -e
  if [ "{{ target }}" == "release" ]; then
    cargo fmt --check
  else
    cargo fmt
  fi

# requires 1.45 [arg('target', pattern='(release)?')]
build target="":
  #!/usr/bin/env sh
  set -e
  if [ "{{ target }}" == "release" ]; then
    cargo auditable build --locked --release
  else
    cargo auditable build --locked
  fi
  if [ -n "$RUSTC_WRAPPER" ]; then sccache --show-stats || true; fi

# requires 1.45 [arg('target', pattern='(release)?')]
test target="":
  #!/usr/bin/env sh
  set -e
  if [ "{{ target }}" == "release" ]; then
    cargo test --locked --release
  else
    cargo test --locked
  fi
  if [ -n "$RUSTC_WRAPPER" ]; then sccache --show-stats || true; fi

# regenerate Cargo.lock using the toolchain image's cargo (run via `just use-builder update-lock`)
update-lock:
  cargo update -w

clean:
  cargo clean

# requires 1.45 [arg('version', pattern='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')]
cut-release version: && (_addCommitTagPush version "Cargo.*")
  @sed -i -e "s/^version = \".*/version = \"{{ trim_start_match(version, "v") }}\"/" Cargo.toml
  @cargo update -w
