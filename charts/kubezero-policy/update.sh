#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

login_ecr_public
update_helm

../kubezero-metrics/sync_grafana_dashboards.py dashboards.yaml templates/kyverno/grafana-dashboards.yaml

update_docs
