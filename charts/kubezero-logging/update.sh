#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

update_helm

FLUENT_BIT_VERSION=$(yq eval '.dependencies[] | select(.name=="fluent-bit") | .version' Chart.yaml)
FLUENTD_VERSION=$(yq eval '.dependencies[] | select(.name=="fluentd") | .version' Chart.yaml)

# fluent-bit
# patch_chart fluent-bit

# FluentD
patch_chart fluentd
rm -f charts/fluentd/templates/files.conf/systemd.yaml

# Fetch dashboards from Grafana.com and update ZDT CM
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/fluent-bit/grafana-dashboards.yaml
../kubezero-metrics/sync_grafana_dashboards.py dashboards-es.yaml templates/eck/grafana-dashboards.yaml

update_docs
