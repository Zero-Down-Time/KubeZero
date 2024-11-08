#!/bin/bash
set -eE
set -o pipefail

KUBE_VERSION=v1.30

ARGO_APP=${1:-/tmp/new-kubezero-argoapp.yaml}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck disable=SC1091
[ -n "$DEBUG" ] && set -x

. "$SCRIPT_DIR"/libhelm.sh

ARGOCD=$(argo_used)

echo "Checking that all pods in kube-system are running ..."
#waitSystemPodsRunning

[ "$ARGOCD" == "True" ] && disable_argo

control_plane_upgrade kubeadm_upgrade

echo "Control plane upgraded, <Return> to continue"
read -r

#echo "Adjust kubezero values as needed:"
# shellcheck disable=SC2015
#[ "$ARGOCD" == "True" ] && kubectl edit app kubezero -n argocd || kubectl edit cm kubezero-values -n kubezero

### v1.30
kubectl delete runtimeclass crio || true

# upgrade modules
#
# Preload cilium images to running nodes
all_nodes_upgrade "chroot /host crictl pull quay.io/cilium/cilium:v1.16.3"

control_plane_upgrade "apply_network, apply_addons, apply_storage, apply_operators"

echo "Checking that all pods in kube-system are running ..."
waitSystemPodsRunning

echo "Applying remaining KubeZero modules..."

control_plane_upgrade "apply_cert-manager, apply_istio, apply_istio-ingress, apply_istio-private-ingress, apply_logging, apply_metrics, apply_telemetry, apply_argo"

# Final step is to commit the new argocd kubezero app
# remove the del(.spec.source.helm.values) with 1.31
kubectl get app kubezero -n argocd -o yaml | yq 'del(.spec.source.helm.values) | del(.status) | del(.metadata) | del(.operation) | .metadata.name="kubezero" | .metadata.namespace="argocd"' | yq 'sort_keys(..)' > $ARGO_APP

# Trigger backup of upgraded cluster state
kubectl create job --from=cronjob/kubezero-backup kubezero-backup-$KUBE_VERSION -n kube-system
while true; do
  kubectl wait --for=condition=complete job/kubezero-backup-$KUBE_VERSION -n kube-system 2>/dev/null && kubectl delete job kubezero-backup-$KUBE_VERSION -n kube-system && break
  sleep 1
done

echo "Please commit $ARGO_APP as the updated kubezero/application.yaml for your cluster."
echo "Then head over to ArgoCD for this cluster and sync all KubeZero modules to apply remaining upgrades."

echo "<Return> to continue and re-enable ArgoCD:"
read -r

[ "$ARGOCD" == "True" ] && enable_argo
