#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

export ISTIO_VERSION=$(yq eval '.dependencies[] | select(.name=="gateway") | .version' Chart.yaml)

# Keep the pinned proxy image (podAnnotations) in sync with the gateway version.
# Variant must match istiod's global.variant in kubezero-istio (distroless).
yq eval -i ".gateway.podAnnotations.\"sidecar.istio.io/proxyImage\" = \"docker.io/istio/proxyv2:${ISTIO_VERSION}-distroless\"" values.yaml

patch_chart gateway

update_docs
