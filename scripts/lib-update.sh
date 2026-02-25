#!/bin/bash
# set -x

update_jsonnet() {
  which jsonnet >/dev/null || {
    echo "Required jsonnet not found!"
    exit 1
  }
  which jb >/dev/null || {
    echo "Required jb ( json-bundler ) not found!"
    exit 1
  }

  [ -r jsonnetfile.json ] || jb init
  [ -r jsonnetfile.lock.json ] && jb update
}

update_helm() {
  #helm repo update
  helm dep update
}

# AWS public ECR
login_ecr_public() {
  aws ecr-public get-login-password \
    --region us-east-1 | helm registry login \
    --username AWS \
    --password-stdin public.ecr.aws
}

# Wrap a yaml with a Helm condition
wrap_with_condition() {
  YAML=$1
  CONDITION=$2

  [ -r $YAML ] || return 1
  sed -i "1 i\\{{- if $2 }}" $YAML
  echo '{{- end }}' >>$YAML
}

get_extract_chart() {
  local CHART=$1
  local VERSION=$(yq eval '.dependencies[] | select(.name=="'$CHART'") | .version' Chart.yaml)

  if [ -z "$CHART" ]; then
    echo "Missing chart"
    exit 1
  fi

  rm -rf charts/$CHART

  # If helm already pulled the chart archive use it
  if [ -f charts/$CHART-$VERSION.tgz ]; then
    tar xfvz charts/$CHART-$VERSION.tgz -C charts && rm charts/$CHART-$VERSION.tgz

  # otherwise parse Chart.yaml and get it
  else
    local REPO=$(yq eval '.dependencies[] | select(.name=="'$CHART'") | .repository' Chart.yaml)
    local URL=$(curl -s $REPO/index.yaml | yq '.entries."'$CHART'".[] | select (.version=="'$VERSION'") | .urls[0]')

    wget -qO - $URL | tar xfvz - -C charts
  fi
}

patch_chart() {
  local CHART=$1
  local KEEP_ORIG=$2

  get_extract_chart $CHART

  [ -n "$KEEP_ORIG" ] && cp -r charts/$CHART charts/${CHART}.orig

  [ -r $CHART.patch ] && patch -p0 -i $CHART.patch --no-backup-if-mismatch || true
}

patch_rebase() {
  local CHART=$1

  get_extract_chart $CHART

  cp -r charts/$CHART charts/$CHART.orig

  patch -p0 -i $CHART.patch --no-backup-if-mismatch
}

patch_create() {
  local CHART=$1

  diff -rtuN charts/$CHART.orig charts/$CHART >$CHART.patch
  rm -rf charts/$CHART.orig
}

update_docs() {
  helm-docs
}
