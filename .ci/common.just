# Recipes shared across language toolchains (rust, python, ...)

# Scan source code for secrets
[no-cd]
scan-src:
  #!/usr/bin/env bash
  set -eo pipefail
  [ -n "$BETTERLEAKS_SRC_FILE" ] && BETTERLEAKS_SRC_OPTS="--no-banner --no-color --report-path $BETTERLEAKS_SRC_FILE --report-format sarif"
  betterleaks dir . --validation=false --exit-code 0 $BETTERLEAKS_SRC_OPTS
