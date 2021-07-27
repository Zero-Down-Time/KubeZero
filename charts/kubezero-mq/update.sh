#!/bin/bash
set -ex

## NATS

NATS_VERSION=0.8.4
rm -rf charts/nats && curl -L -s -o - https://github.com/nats-io/k8s/releases/download/v$NATS_VERSION/nats-$NATS_VERSION.tgz | tar xfz - -C charts

# Fetch dashboards
../kubezero-metrics/sync_grafana_dashboards.py dashboards-nats.yaml templates/nats/grafana-dashboards.yaml
../kubezero-metrics/sync_grafana_dashboards.py dashboards-rabbitmq.yaml templates/rabbitmq/grafana-dashboards.yaml
