#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

export ISTIO_VERSION=$(yq eval '.dependencies[] | select(.name=="base") | .version' Chart.yaml)
export KIALI_VERSION=$(yq eval '.dependencies[] | select(.name=="kiali-server") | .version' Chart.yaml)

# Get matching istioctl
[ -x istioctl ] && [ "$(./istioctl version --remote=false)" == $ISTIO_VERSION ] || { curl -sL https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istioctl-${ISTIO_VERSION}-linux-amd64.tar.gz | tar xz; chmod +x istioctl; }

# Fetch dashboards from Grafana.com and update ZDT CM
../../scripts/sync_grafana_dashboards.py dashboards.yaml templates/grafana-dashboards.yaml

update_docs
