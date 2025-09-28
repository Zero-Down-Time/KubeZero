#!/bin/bash
# set -x

LOC=$(cd $1; pwd -P)
TMP=$(mktemp -d)
cd $TMP

for f in $(grep -Rl "kind: SealedSecret" $LOC); do
  echo "Re-encrypting: $f"

  csplit -z -s $f -f secret- -b %02d.yaml '/^---$/' '{*}'

  for s in secret-*.yaml; do
    kubeseal --re-encrypt -f $s -w new -o yaml && cat new >> $f.new && rm new $s
    echo "---" >> $f.new
  done

  head -n -1 $f.new > $f && rm $f.new
done
