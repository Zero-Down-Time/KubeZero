#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

ECK_VERSION=$(yq eval '.dependencies[] | select(.name=="eck-operator") | .version' Chart.yaml)

update_helm

# fix ECK crds handling to adhere to proper helm v3 support which also fixes ArgoCD applying updates on upgrades
patch_chart eck-operator

mkdir charts/eck-operator/crds
helm template charts/eck-operator/charts/eck-operator-crds --name-template logging --kube-version 1.26 > charts/eck-operator/crds/all-crds.yaml

rm -rf charts/eck-operator/charts
yq eval -Mi 'del(.dependencies)' charts/eck-operator/Chart.yaml

# Create ZDT dashboard configmap
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/cloudnative-pg/grafana-dashboards.yaml

update_docs
