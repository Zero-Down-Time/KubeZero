### Git 

# Parse version from latest git semver tag, use short commit otherwise.
#
# Monorepo per-service versioning overrides the match pattern via the TAG_MATCH
# *env var* (e.g. Jenkins `config.env: ['TAG_MATCH=api-users/v*.*.*']`, or
# `TAG_MATCH=api-users/v*.*.* just …`), or via `just tag_match='…'`.
tag_match := env_var_or_default("TAG_MATCH", "v*.*.*")

# `root` anchors git to the consumer (super)project
root := shell('r="$(git rev-parse --show-superproject-working-tree 2>/dev/null)"; echo "${r:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)}"')
git_tag := shell('(git -C "$1" describe --tags --first-parent --match "$2" --dirty 2>/dev/null || git -C "$1" describe --first-parent --match="" --always --dirty 2>/dev/null || echo "untagged") | sed "s#^[^/]*/##" | tr "[:upper:]" "[:lower:]"', root, tag_match)
git_branch := shell('git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD"', root)
git_repo_name := shell('basename -s .git "$(git -C "$1" config --get remote.origin.url 2>/dev/null || echo unknown)" | tr "[:upper:]" "[:lower:]"', root)

# Compute tag with branch suffix if needed
tag := if git_branch =~ "^(main|master)$" {
  git_tag
} else if git_tag =~ git_branch {
  git_tag
} else if git_tag == git_branch {
  git_tag
} else {
  git_tag + "-" + replace_regex(git_branch, "[^a-zA-Z0-9]+", "-")
}

# "true" when HEAD is exactly on a release tag matching tag_match, else "false".
is_release := shell('git -C "$1" describe --tags --exact-match --match "$2" >/dev/null 2>&1 && echo true || echo false', root, tag_match)

[confirm("Commit, tag and push ?")]
_addCommitTagPush version +files:
  git add {{ files }}
  git commit -m "ci: Release {{ version }}"
  git tag -a {{ version }} -m"Release: {{ version }}"
  git push && git push --tags


### OS
# Build arch, overridable from the environment so Jenkins (or a per-arch matrix)
# can drive a single source of truth for both `--platform` and derived values.
arch := env_var_or_default("ARCH", "amd64")
all_archs := "amd64 arm64"

# Validate architecture (defaults to amd64)
_validate-arch arch="amd64":
  #!/usr/bin/env bash
  if [[ "{{arch}}" != "amd64" && "{{arch}}" != "arm64" ]]; then
    echo "Error: Invalid arch '{{arch}}'. Must be 'amd64' or 'arm64'"
    exit 1
  fi

_git-debug: (_validate-arch arch)
  @echo "tag: {{git_tag}} branch: {{ git_branch }} on {{arch}}".

# Echo the bare git_tag value (used by container build/push and by Jenkins
# to capture the actual published tag for downstream stages).
[no-cd]
_print-tag:
  @echo {{ git_tag }}

# Echo the bare is_release value (true/false). Consumed by Jenkins' changeset
# gate to force a build for tagged releases; mirrors _print-tag echoing git_tag.
[no-cd]
_is-release:
  @echo {{ is_release }}

# update the shared .ci submodule to the latest of its tracked branch
ci-pull-upstream:
	git submodule update --remote --merge .ci

cleanup-tags tag:
  #!/usr/bin/env bash
  if ! git rev-parse "refs/tags/{{tag}}" >/dev/null 2>&1; then
    echo "Error: tag {{tag}} does not exist" >&2
    exit 1
  fi

  TAGS=$(git tag --sort=version:refname | sed "/{{tag}}/q" | head -n -1)
  COUNT=$(echo "$TAGS" | grep -c . || true)
  echo "Deleting $COUNT tags up to {{tag}}"

  if [ "$COUNT" -gt 0 ]; then
    echo "$TAGS" | xargs -I{} git tag -d {}
    echo "$TAGS" | sed 's|.*|:refs/tags/&|' | xargs git push origin
  fi
