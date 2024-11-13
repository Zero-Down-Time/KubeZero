#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

# Create ZDT dashboard, alerts etc configmaps
cd jsonnet && make

../sync_grafana_dashboards.py metrics-dashboards.yaml ../templates/grafana-dashboards-metrics.yaml
../sync_grafana_dashboards.py k8s-dashboards.yaml ../templates/grafana-dashboards-k8s.yaml
../sync_grafana_dashboards.py zdt-dashboards.yaml ../templates/grafana-dashboards-zdt.yaml

../sync_prometheus_rules.py k8s-rules.yaml ../templates/rules
cd -

# Delete not used upstream dashboards or rules
rm -rf charts/kube-prometheus-stack/templates/grafana/dashboards-1.14 charts/kube-prometheus-stack/templates/prometheus/rules-1.14

update_docs
