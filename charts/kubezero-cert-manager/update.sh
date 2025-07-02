#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

update_helm

update_docs

cd jsonnet

update_jsonnet

# Install cert-mamanger mixin
jb install github.com/imusmanmalik/cert-manager-mixin@main

# Install rules
rm -rf rules && mkdir -p rules
jsonnet -J vendor -m rules rules.jsonnet
../../kubezero-metrics/sync_prometheus_rules.py ../prometheus-rules.yaml ../templates

# Fetch dashboards from Grafana.com and update ZDT CM
../../kubezero-metrics/sync_grafana_dashboards.py ../dashboards.yaml ../templates/grafana-dashboards.yaml
