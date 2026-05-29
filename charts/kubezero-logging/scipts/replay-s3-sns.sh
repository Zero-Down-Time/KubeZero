#!/usr/bin/env bash
#
# replay-s3-sns.sh
#   Backfill helper. Lists every object under an s3:// URL and publishes one
#   SNS notification per object so a subscriber (SNS -> SQS -> consumer)
#   re-ingests already-existing files. The objects themselves are NOT
#   modified; the consumer must still fetch each key from S3.
#
#   Two output shapes (--format):
#     cloudtrail   CloudTrail's native SNS shape (default; what CloudTrail
#                  itself emits when configured with an SNS topic):
#                    {"s3Bucket":"<bucket>","s3ObjectKey":["<key>"]}
#     s3-put       Standard S3 Event Notification "ObjectCreated:Put":
#                    {"Records":[{"eventSource":"aws:s3","s3":{...}}, ...]}
#                  Use this for backfill of CloudFront access logs, VPC flow
#                  logs, or any pipeline that consumes raw S3 events.
#
# Usage:
#   ./replay-s3-sns.sh s3://bucket/prefix/ --topic-arn arn:aws:sns:... \
#       [--format cloudtrail|s3-put] [--configuration-id replay] \
#       [--region us-east-1] [--concurrency 8] [--dry-run]
#
# Requires: bash 4.3+, aws CLI v2, jq.  (Alpine: apk add bash jq aws-cli)
#
set -euo pipefail

# ----------------------------------------------------------------------------
# defaults / args
# ----------------------------------------------------------------------------
CONCURRENCY=8
DRY_RUN=0
TOPIC_ARN=""
REGION=""              # bucket region (event awsRegion); auto-detected if empty
FORMAT="cloudtrail"    # cloudtrail | s3-put
CONFIGURATION_ID="replay"
S3_URL=""

usage() { sed -n '2,24p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --topic-arn)        TOPIC_ARN="$2"; shift 2;;
    --region)           REGION="$2";    shift 2;;
    --concurrency)      CONCURRENCY="$2"; shift 2;;
    --format)           FORMAT="$2"; shift 2;;
    --configuration-id) CONFIGURATION_ID="$2"; shift 2;;
    --dry-run)          DRY_RUN=1; shift;;
    -h|--help)          usage; exit 0;;
    s3://*)             S3_URL="$1"; shift;;
    *) echo "unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$S3_URL" ]] || { echo "error: an s3:// URL is required" >&2; exit 1; }
[[ $DRY_RUN -eq 1 || -n "$TOPIC_ARN" ]] || { echo "error: --topic-arn required (or use --dry-run)" >&2; exit 1; }
case "$FORMAT" in
  cloudtrail|s3-put) ;;
  *) echo "error: --format must be 'cloudtrail' or 's3-put'" >&2; exit 1;;
esac
command -v jq  >/dev/null || { echo "error: jq not found"  >&2; exit 1; }
command -v aws >/dev/null || { echo "error: aws not found" >&2; exit 1; }

# ----------------------------------------------------------------------------
# parse bucket / prefix
# ----------------------------------------------------------------------------
rest="${S3_URL#s3://}"
BUCKET="${rest%%/*}"
PREFIX=""
[[ "$rest" == */* ]] && PREFIX="${rest#*/}"

PREFIX_ARGS=()
[[ -n "$PREFIX" ]] && PREFIX_ARGS=(--prefix "$PREFIX")

# bucket region -> used for the event's awsRegion field
if [[ -z "$REGION" ]]; then
  loc="$(aws s3api get-bucket-location --bucket "$BUCKET" --query 'LocationConstraint' --output text 2>/dev/null || true)"
  case "$loc" in
    None|""|null) REGION="us-east-1";;
    EU)           REGION="eu-west-1";;
    *)            REGION="$loc";;
  esac
fi

# SNS call region comes from the topic ARN (may differ from the bucket region)
SNS_REGION=""
[[ -n "$TOPIC_ARN" ]] && SNS_REGION="$(cut -d: -f4 <<<"$TOPIC_ARN")"

FAIL_LOG="replay-${FORMAT}-failures-$(date +%Y%m%dT%H%M%SZ).jsonl"

echo "bucket=$BUCKET prefix='${PREFIX}' bucket_region=$REGION sns_region=${SNS_REGION:-n/a} format=$FORMAT concurrency=$CONCURRENCY dry_run=$DRY_RUN" >&2

# ----------------------------------------------------------------------------
# jq builders: one S3 page (.Contents[]) -> compact batches of <=10 entries.
#   Both filters skip folder markers (Key endswith "/") and zero-byte objects.
#   Output: one batch (JSON array of {Id, Message}) per line.
# ----------------------------------------------------------------------------

# CloudTrail's native SNS shape — key is RAW (not URL-encoded).
read -r -d '' JQ_CLOUDTRAIL <<'JQEOF' || true
def chunks($n): [range(0; length; $n) as $i | .[$i:$i+$n]];
(.Contents // [])
| map(select((.Key | endswith("/")) | not) | select(.Size > 0))
| to_entries
| map({
    Id: (.key | tostring),
    Message: ({ s3Bucket: $bucket, s3ObjectKey: [ .value.Key ] } | tojson)
  })
| chunks(10) | .[]
JQEOF

# Standard S3 Event Notification "ObjectCreated:Put" — eventTime/size/eTag
# come from the ListObjectsV2 record. ETag in the API response is wrapped in
# literal double-quotes; strip them. Key is RAW (real S3 events URL-encode it,
# but most consumers decode either form — match the cloudtrail mode here).
read -r -d '' JQ_S3_PUT <<'JQEOF' || true
def chunks($n): [range(0; length; $n) as $i | .[$i:$i+$n]];
(.Contents // [])
| map(select((.Key | endswith("/")) | not) | select(.Size > 0))
| to_entries
| map({
    Id: (.key | tostring),
    Message: ({
      Records: [{
        eventVersion: "2.1",
        eventSource:  "aws:s3",
        awsRegion:    $region,
        eventTime:    .value.LastModified,
        eventName:    "ObjectCreated:Put",
        s3: {
          s3SchemaVersion: "1.0",
          configurationId: $configurationId,
          bucket: {
            name: $bucket,
            arn:  ("arn:aws:s3:::" + $bucket)
          },
          object: {
            key:  .value.Key,
            size: .value.Size,
            eTag: (.value.ETag | gsub("\""; ""))
          }
        }
      }]
    } | tojson)
  })
| chunks(10) | .[]
JQEOF

if [[ "$FORMAT" == "s3-put" ]]; then JQ="$JQ_S3_PUT"; else JQ="$JQ_CLOUDTRAIL"; fi

# ----------------------------------------------------------------------------
# producer: stream batch arrays (one compact JSON array per line)
# ----------------------------------------------------------------------------
build_batches() {
  local token="" page
  while :; do
    if [[ -n "$token" ]]; then
      page="$(aws s3api list-objects-v2 --region "$REGION" --bucket "$BUCKET" \
                "${PREFIX_ARGS[@]+"${PREFIX_ARGS[@]}"}" \
                --max-items 1000 --starting-token "$token" --output json)"
    else
      page="$(aws s3api list-objects-v2 --region "$REGION" --bucket "$BUCKET" \
                "${PREFIX_ARGS[@]+"${PREFIX_ARGS[@]}"}" \
                --max-items 1000 --output json)"
    fi
    jq -c --arg bucket "$BUCKET" \
          --arg region "$REGION" \
          --arg configurationId "$CONFIGURATION_ID" \
          "$JQ" <<<"$page"
    token="$(jq -r '.NextToken // empty' <<<"$page")"
    [[ -z "$token" ]] && break
  done
}

# ----------------------------------------------------------------------------
# publish one batch (with retry/backoff); log to FAIL_LOG if it can't succeed
# ----------------------------------------------------------------------------
publish_batch() {
  local entries="$1" attempt=0 max=5 resp failed
  if [[ $DRY_RUN -eq 1 ]]; then
    jq -c '.[].Message | fromjson' <<<"$entries"
    return 0
  fi
  while :; do
    if resp="$(aws sns publish-batch --region "$SNS_REGION" --topic-arn "$TOPIC_ARN" \
                 --publish-batch-request-entries "$entries" 2>&1)"; then
      failed="$(jq '.Failed | length' <<<"$resp" 2>/dev/null || echo 1)"
      [[ "$failed" == "0" ]] && return 0
    fi
    attempt=$((attempt + 1))
    if (( attempt >= max )); then
      printf '%s\n' "$entries" >>"$FAIL_LOG"
      echo "WARN: batch failed after ${max} attempts -> $FAIL_LOG" >&2
      return 0
    fi
    sleep $(( 2 ** attempt ))   # 2,4,8,16s backoff
  done
}

# ----------------------------------------------------------------------------
# consumer: bounded-concurrency dispatch with progress
# ----------------------------------------------------------------------------
run() {
  local active=0 batches=0
  local conc="$CONCURRENCY"
  [[ $DRY_RUN -eq 1 ]] && conc=1   # keep dry-run output readable
  while IFS= read -r batch; do
    publish_batch "$batch" &
    active=$((active + 1)); batches=$((batches + 1))
    if (( active >= conc )); then wait -n; active=$((active - 1)); fi
    if (( batches % 50 == 0 )); then echo "...dispatched ~$((batches * 10)) objects" >&2; fi
  done
  wait
  echo "done: ~$((batches * 10)) objects (max) across $batches batches" >&2
  [[ -s "$FAIL_LOG" ]] && echo "failures logged to $FAIL_LOG (re-run with each line as --publish-batch-request-entries)" >&2 || true
}

build_batches | run
