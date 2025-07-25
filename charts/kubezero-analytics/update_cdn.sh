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

trap cleanup EXIT

cd $TEMP_DIR

git clone  https://github.com/plausible/analytics.git --depth 1

cd analytics/tracker

yarn install

node compile.js

cd ../priv/tracker/js

aws s3 sync --delete --include "plausible*" --exclude "*compat*" . s3://zero-downtime-web-cdn/plausible/
