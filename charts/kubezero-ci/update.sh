#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

patch_chart jenkins

# Create ZDT dashboard configmap
../kubezero-metrics/sync_grafana_dashboards.py dashboard-jenkins.yaml templates/jenkins/grafana-dashboard.yaml
../kubezero-metrics/sync_grafana_dashboards.py dashboard-forgejo.yaml templates/forgejo/grafana-dashboard.yaml

#Gitea dark theme
# https://codeberg.org/pat-s/gitea-github-theme

update_docs
