#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

update_helm

# Vector: tpl extraVolumes/extraVolumeMounts so the optional geoip DB mount can be gated
patch_chart vector

# OSD dashboards-vector
./scipts/sync-osd-dashboards.sh

FLUENT_BIT_VERSION=$(yq eval '.dependencies[] | select(.name=="fluent-bit") | .version' Chart.yaml)
FLUENTD_VERSION=$(yq eval '.dependencies[] | select(.name=="fluentd") | .version' Chart.yaml)

# fluent-bit
# patch_chart fluent-bit

# FluentD
patch_chart fluentd
rm -f charts/fluentd/templates/files.conf/systemd.yaml

# Fetch dashboards from Grafana.com and update ZDT CM
../../scripts/sync_grafana_dashboards.py dashboards.yaml templates/fluent-bit/grafana-dashboards.yaml
../../scripts/sync_grafana_dashboards.py dashboards-es.yaml templates/eck/grafana-dashboards.yaml
../../scripts/sync_grafana_dashboards.py dashboards-vector.yaml templates/vector/grafana-dashboards.yaml

update_docs
