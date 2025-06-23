#!/bin/bash

. ../../scripts/lib-update.sh

update_helm

patch_chart argo-cd

# Create ZDT dashboard configmap
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/argo-cd/grafana-dashboards.yaml

update_docs
