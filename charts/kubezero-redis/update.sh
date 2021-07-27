#!/bin/bash

# Fetch dashboards from Grafana.com and update ZDT CM
../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/grafana-dashboards.yaml
