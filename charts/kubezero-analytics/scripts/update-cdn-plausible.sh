#!/bin/bash

CWD=$(pwd)
TEMP_DIR=$(mktemp -d)

cleanup() {
  cd $CWD
  if [ -d "$TEMP_DIR" ]; then
      echo "Cleaning up temporary directory: $TEMP_DIR"
      rm -rf "$TEMP_DIR"
  fi
}

#  trap cleanup EXIT

echo "Using $TEMP_DIR as workspace"
cd $TEMP_DIR

git clone  https://github.com/plausible/analytics.git --depth 1

cd analytics/tracker

yarn install

node compile.js

cd ../priv/tracker/js

# We dont need to support legacy
rm *compat*

# rename files to match upstream to make Hugo module happy
for f in plausible.*.js; do
  mv $f script.${f#plausible.}
done

ls

aws s3 sync --delete --include "script.*" . s3://zero-downtime-web-cdn/plausible/js/
