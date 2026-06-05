#!/usr/bin/env bash
#
# bootstrap-tokens.sh — issue HTTP-ingest bearer tokens for the Vector aggregator.
#
# Generates one opaque token per tenant, stores only its SHA-256 in tokens.csv,
# and creates/updates the `vector-http-tokens` Secret. Plaintext tokens are
# printed ONCE (hand them to senders) and never persisted — they cannot be
# recovered from the hash.
#
# Usage:
#   ./bootstrap-tokens.sh [options] TENANT [TENANT ...]
#
# Options:
#   -n NS        Namespace               (default: vector)
#   -s NAME      Secret name             (default: vector-http-tokens)
#   -t STS       StatefulSet to restart  (default: logging-vector)
#   -p PREFIX    Token prefix            (default: vlog_)
#   -a           Append to existing tokens (preserve current rows)
#   -r           Rollout-restart the StatefulSet so Vector reloads the table
#   -h           Help
#
# Examples:
#   ./bootstrap-tokens.sh payments edge
#   ./bootstrap-tokens.sh -n vector -a -r newvendor

set -euo pipefail

NS="logging"
SECRET="vector-http-tokens"
STS="logging-vector"
PREFIX="zdt_vlog_"
APPEND=false
RESTART=false

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while getopts ":n:s:t:p:arh" opt; do
  case "$opt" in
  n) NS="$OPTARG" ;;
  s) SECRET="$OPTARG" ;;
  t) STS="$OPTARG" ;;
  p) PREFIX="$OPTARG" ;;
  a) APPEND=true ;;
  r) RESTART=true ;;
  h) usage 0 ;;
  *)
    echo "unknown option: -$OPTARG" >&2
    usage 1
    ;;
  esac
done
shift $((OPTIND - 1))

[ "$#" -ge 1 ] || {
  echo "error: provide at least one TENANT" >&2
  usage 1
}
for bin in kubectl openssl; do
  command -v "$bin" >/dev/null || {
    echo "error: '$bin' not found in PATH" >&2
    exit 1
  }
done

# --- helpers ---------------------------------------------------------------
sha256_hex() { # lowercase hex of the exact bytes (no trailing newline) — matches VRL sha2()
  if command -v sha256sum >/dev/null; then
    printf '%s' "$1" | sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null; then
    printf '%s' "$1" | shasum -a 256 | cut -d' ' -f1
  else printf '%s' "$1" | openssl dgst -sha256 | awk '{print $NF}'; fi
}
b64d() { base64 --decode 2>/dev/null || base64 -d 2>/dev/null || base64 -D; }
gen_token() { printf '%s%s' "$PREFIX" "$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')"; }

# --- build the CSV (header + rows) -----------------------------------------
CSV="$(mktemp)"
trap 'rm -f "$CSV"' EXIT
chmod 600 "$CSV"
echo "token_sha256,tenant,active" >"$CSV"

if [ "$APPEND" = true ]; then
  if existing="$(kubectl -n "$NS" get secret "$SECRET" -o jsonpath='{.data.tokens\.csv}' 2>/dev/null)" &&
    [ -n "$existing" ]; then
    printf '%s' "$existing" | b64d | tail -n +2 | sed '/^[[:space:]]*$/d' >>"$CSV" || true
  fi
fi

declare -a ISSUED=()
for tenant in "$@"; do
  tok="$(gen_token)"
  printf '%s,%s,true\n' "$(sha256_hex "$tok")" "$tenant" >>"$CSV"
  ISSUED+=("$tenant=$tok")
done

# --- apply the Secret (idempotent) -----------------------------------------
kubectl -n "$NS" create secret generic "$SECRET" \
  --from-file=tokens.csv="$CSV" \
  --dry-run=client -o yaml | kubectl apply -f -

if [ "$RESTART" = true ]; then
  kubectl -n "$NS" rollout restart "statefulset/$STS"
fi

# --- hand out the plaintext (printed once) ---------------------------------
echo
echo "=== issued tokens — copy now, they are NOT stored anywhere ==="
for entry in "${ISSUED[@]}"; do
  printf '  %-16s Authorization: %s\n' "${entry%%=*}:" "${entry#*=}"
done
echo "=============================================================="
[ "$RESTART" = true ] || echo "note: run with -r (or rollout-restart $STS) so Vector reloads the table."
