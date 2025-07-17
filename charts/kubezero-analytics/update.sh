#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

update_helm

patch_chart plausible-analytics

# Remove test pods
rm -rf charts/plausible-analytics/templates/tests

update_docs
