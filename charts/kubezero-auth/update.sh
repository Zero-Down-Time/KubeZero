#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

login_ecr_public
update_helm

#patch_chart keycloakx

# Fetch dashboards
../kubezero-metrics/sync_grafana_dashboards.py dashboards-keycloak.yaml templates/keycloakx/grafana-dashboards.yaml

update_docs
