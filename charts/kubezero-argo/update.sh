#!/bin/bash

. ../../scripts/lib-update.sh

update_helm

patch_chart argo-cd

# Create ZDT dashboard configmap
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/argo-cd/grafana-dashboards.yaml

update_docs

ARGOCD_VERSION=$(yq eval '.appVersion' charts/argo-cd/Chart.yaml)

# Get matching istioctl
[ -x argocd ] && [ "$(./argocd version --short --client | awk '{print $2}' | sed -e 's/+.*//')" == $ARGOCD_VERSION ] || { curl -sL -o argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64; chmod +x argocd; }
