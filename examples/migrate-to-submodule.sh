#!/usr/bin/env bash
# examples/migrate-to-submodule.sh
#
# One-time migration of a consumer repo's .ci/ from a vendored git subtree to a
# git submodule. Run from the consumer repo root. Stages the change but does not
# commit or push — review first.
#
# Source location is configurable so consumers can point at their own mirror:
#   CI_TOOLS_URL     upstream/mirror clone URL  (default: canonical ZDT Forgejo)
#   CI_TOOLS_BRANCH  tracked branch             (default: main)
# e.g.  CI_TOOLS_URL=https://forgejo.example.com/infra/ci-tools-lib.git ./migrate-to-submodule.sh
#
# After running: enable Renovate's submodule manager (see examples/renovate.json),
# configure the multibranch source to recurse submodules, and tell teammates to
# re-clone with --recurse-submodules (or run `git submodule update --init`).
set -euo pipefail

URL="${CI_TOOLS_URL:-https://git.zero-downtime.net/ZeroDownTime/ci-tools-lib.git}"
BRANCH="${CI_TOOLS_BRANCH:-main}"

cd "$(git rev-parse --show-toplevel)"

# Migration rewrites .ci/, so refuse to run on a dirty tree.
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is dirty; commit or stash first." >&2
  exit 1
fi

if [ -f .gitmodules ] && grep -q 'path = .ci$' .gitmodules; then
  echo ".ci is already a submodule — nothing to do."
  exit 0
fi

# Drop the vendored subtree copy (tracked files under .ci/).
if [ -e .ci ]; then
  git rm -r --quiet .ci
  rm -rf .ci
fi

# -b records the tracked branch in .gitmodules, which is what Renovate's
# git-submodules manager follows.
git submodule add -b "$BRANCH" "$URL" .ci
git add .gitmodules .ci

cat <<EOF

Done. .ci is now a submodule tracking '${BRANCH}' from ${URL}.
Review the staged changes, then:

  git commit -m "Convert .ci to git submodule"

Then enable Renovate (examples/renovate.json) and submodule recursion on the
Jenkins multibranch source. See the ci-tools-lib README "Maintenance" section.
EOF
