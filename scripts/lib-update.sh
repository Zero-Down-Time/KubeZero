#!/bin/bash
set -ex

# prometheus metrics mixin branch
# https://github.com/prometheus-operator/kube-prometheus#compatibility
KUBE_PROMETHEUS_RELEASE=main

update_jsonnet() {
  which jsonnet > /dev/null || { echo "Required jsonnet not found!"; exit 1;}
  which jb > /dev/null || { echo "Required jb ( json-bundler ) not found!"; exit 1;}

  # remove previous versions
  rm -f jsonnetfile.json jsonnetfile.lock.json

  jb init
  jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main
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

get_extract_chart() {
  local CHART=$1
  local VERSION=$(yq eval '.dependencies[] | select(.name=="'$CHART'") | .version' Chart.yaml)

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

  get_extract_chart $CHART

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

  diff -rtuN charts/$CHART.orig charts/$CHART > $CHART.patch
  rm -rf charts/$CHART.orig
}

update_docs() {
  helm-docs
}
