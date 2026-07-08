# GitOps writeback: commit yq-path updates (typically image tags / digests)
# to a manifests repository so a downstream sync engine (ArgoCD, Flux, ...)
# picks up the change. Local dev and Jenkins use the same recipes.
#
# Updates spec format (JSON file passed by path):
#   {
#     "<file-relative-to-repo-root>": {
#       "<yq-expression>": "<desired-value>",
#       ...
#     },
#     ...
#   }
#
# Local usage (post-build promotion):
#   echo '{"apps/payments/values.yaml":{".image.tag":"v1.2.3"}}' > /tmp/u.json
#   just gitops::update git@forgejo.example.com:zdt/infra.git main /tmp/u.json
#
# PR mode (push side only — opening the PR itself runs from Jenkins via
# `forgejo.openPullRequest` in vars/forgejo.groovy):
#   just gitops::update <repo> main /tmp/u.json pr promote/payments-1
#
# Commit message: read from $GITOPS_COMMIT_MESSAGE; falls back to a generic
# "ci: gitops update" if unset. Jenkins (vars/updateGitops.groovy) always
# supplies a rich auto-generated message.
#
# Tools required on PATH: git, yq (mikefarah), jq.

git_user_name := env_var_or_default("GIT_USER_NAME", "jenkins-ci")
git_user_email := env_var_or_default("GIT_USER_EMAIL", "jenkins@ci.local")
gitops_max_retries := env_var_or_default("GITOPS_MAX_RETRIES", "5")

# Clone, idempotency-check, optional PR-branch setup, edit, commit, push with
# rebase-retry. Re-applies edits each retry so the final tree is deterministic
# regardless of how many concurrent CI runs raced. mode=pr uses
# --force-with-lease against the captured remote SHA on the PR branch.
update repo base updates_json mode="push" pr_branch="":
  #!/usr/bin/env bash
  set -euo pipefail

  if [[ "{{ mode }}" != "push" && "{{ mode }}" != "pr" ]]; then
    echo "gitops::update: mode must be 'push' or 'pr' (got '{{ mode }}')" >&2
    exit 2
  fi
  if [ "{{ mode }}" = "pr" ] && [ -z "{{ pr_branch }}" ]; then
    echo "gitops::update: pr_branch is required when mode=pr" >&2
    exit 2
  fi

  workdir=$(mktemp -d -t gitops-XXXXXXXX)
  trap "rm -rf '$workdir'" EXIT

  # PR mode rebases onto the base branch; needs full history.
  if [ "{{ mode }}" = "pr" ]; then
    git clone --no-single-branch --branch '{{ base }}' '{{ repo }}' "$workdir"
  else
    git clone --depth=1 --branch '{{ base }}' '{{ repo }}' "$workdir"
  fi
  cd "$workdir"

  # NUL-delimited (file, path, value) triples from the spec.
  jq_iter='to_entries[] as $f | $f.value | to_entries[] | "\($f.key)\u0000\(.key)\u0000\(.value)\u0000"'

  # Idempotency: skip if every yq path already matches its desired value.
  needs=1
  while IFS= read -r -d '' file && IFS= read -r -d '' path && IFS= read -r -d '' desired; do
    current=$(yq "$path" "$file")
    if [ "$current" != "$desired" ]; then
      needs=0
      break
    fi
  done < <(jq -j "$jq_iter" '{{ updates_json }}')
  if [ "$needs" -eq 1 ]; then
    echo "gitops: all values already at desired - nothing to do" >&2
    exit 0
  fi

  if [ "{{ mode }}" = "pr" ]; then
    if git ls-remote --exit-code --heads origin '{{ pr_branch }}' >/dev/null 2>&1; then
      git fetch origin '{{ pr_branch }}:{{ pr_branch }}'
      git checkout '{{ pr_branch }}'
      git rebase 'origin/{{ base }}'
    else
      git checkout -b '{{ pr_branch }}'
    fi
    target='{{ pr_branch }}'
    force=1
  else
    target='{{ base }}'
    force=0
  fi

  git config user.name '{{ git_user_name }}'
  git config user.email '{{ git_user_email }}'

  msg="${GITOPS_COMMIT_MESSAGE:-ci: gitops update}"

  attempt=0
  while [ "$attempt" -lt {{ gitops_max_retries }} ]; do
    attempt=$((attempt + 1))

    while IFS= read -r -d '' file && IFS= read -r -d '' path && IFS= read -r -d '' value; do
      YQ_VALUE="$value" yq -i "$path = strenv(YQ_VALUE)" "$file"
      git add "$file"
    done < <(jq -j "$jq_iter" '{{ updates_json }}')

    git commit -m "$msg"

    push_rc=0
    if [ "$force" -eq 1 ]; then
      expected=$(git ls-remote origin "$target" 2>/dev/null | awk 'NR==1 {print $1}' || true)
      if [ -n "$expected" ]; then
        git push --force-with-lease="$target:$expected" origin "$target" || push_rc=$?
      else
        git push origin "$target" || push_rc=$?
      fi
    else
      git push origin "$target" || push_rc=$?
    fi

    if [ "$push_rc" -eq 0 ]; then
      git rev-parse HEAD
      exit 0
    fi

    echo "gitops: push rejected (attempt $attempt/{{ gitops_max_retries }}); rebasing onto origin/{{ base }}" >&2
    git fetch origin '{{ base }}'
    git reset --hard 'origin/{{ base }}'
    if [ "$force" -eq 1 ]; then
      git checkout -B "$target"
    fi
  done

  echo "gitops: failed to push after {{ gitops_max_retries }} attempts" >&2
  exit 1

