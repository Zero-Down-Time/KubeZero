#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

login_ecr_public
update_helm

# Abandon for now in favor of KRR
# get latest VPA resources, from https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/hack/vpa-process-yamls.sh
# COMPONENTS="vpa-v1-crd-gen vpa-rbac updater-deployment recommender-deployment admission-controller-deployment"
# mkdir -p templates/vertical-pod-autoscaler
#for c in $COMPONENTS; do
#  wget -q -O templates/vertical-pod-autoscaler/${c}.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/refs/heads/master/vertical-pod-autoscaler/deploy/${c}.yaml
#done

patch_chart aws-eks-asg-rolling-update-handler

update_docs
