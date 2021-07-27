#!/bin/bash

ECK_VERSION=1.6.0
FLUENT_BIT_VERSION=0.15.15
FLUENTD_VERSION=0.2.6

# fix ECK crds handling to adhere to proper helm v3 support which also fixes ArgoCD applying updates on upgrades
helm repo list | grep elastic -qc || { helm repo add elastic https://helm.elastic.co; helm repo update; }

rm -rf charts/eck-operator && helm pull elastic/eck-operator --untar --untardir charts --version $ECK_VERSION

mkdir charts/eck-operator/crds
helm template charts/eck-operator/charts/eck-operator-crds --name-template logging > charts/eck-operator/crds/all-crds.yaml
rm -rf charts/eck-operator/charts
yq d charts/eck-operator/Chart.yaml dependencies -i

# Fluent Bit
rm -rf charts/fluent-bit
curl -L -s -o - https://github.com/fluent/helm-charts/releases/download/fluent-bit-${FLUENT_BIT_VERSION}/fluent-bit-${FLUENT_BIT_VERSION}.tgz | tar xfz - -C charts

patch -i fluent-bit.patch -p0 --no-backup-if-mismatch


# FluentD
rm -rf charts/fluentd
curl -L -s -o - https://github.com/fluent/helm-charts/releases/download/fluentd-${FLUENTD_VERSION}/fluentd-${FLUENTD_VERSION}.tgz | tar xfz - -C charts

patch -i fluentd.patch -p0 --no-backup-if-mismatch

# Fetch dashboards from Grafana.com and update ZDT CM
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/grafana-dashboards.yaml
