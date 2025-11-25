#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

patch_chart kube-prometheus-stack

# Move CRDs from kube-prometheus-stack to top-level
rm -rf templates/crds
mv charts/kube-prometheus-stack/charts/crds/crds templates
rm -rf charts/kube-prometheus-stack/charts/crds

# add ArgoCD server-side apply annotation as App setting seems not working for CRDs
# argocd.argoproj.io/sync-options: ServerSideApply=true
for crd in templates/crds/*.yaml; do
  yq -i '.metadata.annotations."argocd.argoproj.io/sync-options"="ServerSideApply=true"' $crd
done

# make some crds conditional
for c in alertmanagerconfigs prometheusagents prometheusrules alertmanagers prometheuses scrapeconfigs thanosrulers; do
  wrap_with_condition templates/crds/crd-${c}.yaml 'index .Values "kube-prometheus-stack" "prometheus" "enabled"'
done

# Delete not used upstream dashboards or rules
rm -rf charts/kube-prometheus-stack/templates/grafana/dashboards-1.14 charts/kube-prometheus-stack/templates/prometheus/rules-1.14

# Create ZDT dashboard, alerts etc configmaps
rm -rf templates/{rules,dashboards} && mkdir -p templates/{rules,dashboards}

cd jsonnet && make && cd -

./sync_grafana_dashboards.py jsonnet/metrics-dashboards.yaml templates/dashboards/metrics.yaml
./sync_grafana_dashboards.py jsonnet/k8s-dashboards.yaml templates/dashboards/k8s.yaml
./sync_grafana_dashboards.py jsonnet/zdt-dashboards.yaml templates/dashboards/zdt.yaml

./sync_prometheus_rules.py jsonnet/k8s-rules.yaml templates/rules

update_docs
