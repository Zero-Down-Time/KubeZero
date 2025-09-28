#!/bin/bash
#
# Reject pushes that contain commits with messages that do not adhere
# to the defined regex.

# [1] https://www.conventionalcommits.org/en/v1.0.0/#specification

set -e

zero_commit='0000000000000000000000000000000000000000'
msg_regex='^((fixup! |squash! )?(fix|feat|build|chore|ci|docs|style|refactor|perf|test)(?:\(([^\)\s]+)\))?: (.+))(?:\n|$){0,2}?((?:^.+(\n|$))+(?:\n|$){0,2}?)*((?:^.+(\n|$))+)*'

while read -r oldrev newrev refname; do
  # Branch or tag got deleted, ignore the push
  [ "$newrev" = "$zero_commit" ] && continue

  # Calculate range for new branch/updated branch
  [ "$oldrev" = "$zero_commit" ] && range="$newrev" || range="$oldrev..$newrev"

  for commit in $(git rev-list "$range" --not --all); do
    if ! git log --max-count=1 --format=%B $commit | grep -iqE "$msg_regex"; then
      echo "ERROR:"
      echo "ERROR: Your push was rejected because the commit"
      echo "ERROR: $commit in ${refname#refs/heads/}"
      echo "ERROR: is not adhering to convential commit format."
      echo "ERROR:"
      echo "ERROR: Please fix the commit message and push again."
      echo "ERROR: https://www.conventionalcommits.org/en/v1.0.0/#specification"
      echo "ERROR"
      exit 1
    fi
  done
done
