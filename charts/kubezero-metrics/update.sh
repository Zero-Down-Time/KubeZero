#!/bin/bash

VERSION=16.13.0
PG_VER=1.10.1

rm -rf charts/kube-prometheus-stack
helm pull prometheus-community/kube-prometheus-stack --untar --untardir charts --version $VERSION

rm -rf charts/prometheus-pushgateway
helm pull prometheus-community/prometheus-pushgateway --untar --untardir charts --version $PG_VER

# The grpc alerts could be re-enabled with etcd 3.5
# https://github.com/etcd-io/etcd/pull/12196
patch -p0 -i zdt.patch --no-backup-if-mismatch

patch -p0 -i zdt-pushgateway.patch --no-backup-if-mismatch

# Create ZDT dashboard configmap
cd dashboards
./build.sh

# Patch for the apiserver dashboard
patch -p1 -i ../zdt-apiserver-dashboard.patch --no-backup-if-mismatch

../sync_grafana_dashboards.py metrics-dashboards.yaml ../templates/grafana-dashboards-metrics.yaml
../sync_grafana_dashboards.py k8s-dashboards.yaml ../templates/grafana-dashboards-k8s.yaml
../sync_grafana_dashboards.py zdt-dashboards.yaml ../templates/grafana-dashboards-zdt.yaml
cd -
