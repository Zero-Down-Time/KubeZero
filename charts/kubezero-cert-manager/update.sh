#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

update_helm

patch_chart cert-manager

# build cert-mamanger mixin
cd jsonnet
jb install
jsonnet -J vendor -m rules rules.jsonnet
cd -

# Install rules
../kubezero-metrics/sync_prometheus_rules.py prometheus-rules.yaml templates

# Fetch dashboards from Grafana.com and update ZDT CM
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/grafana-dashboards.yaml

update_docs
