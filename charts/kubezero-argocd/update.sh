#!/bin/bash

# Create ZDT dashboard configmap
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/grafana-dashboards.yaml
