#!/bin/bash
set -eE
set -o pipefail

KUBE_VERSION=v1.33

ARGO_APP=${1:-/tmp/new-kubezero-argoapp.yaml}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck disable=SC1091
[ -n "$DEBUG" ] && set -x

. "$SCRIPT_DIR"/libhelm.sh

ARGOCD=$(argo_used)


control_plane_phase1() {
  admin_job "upgrade_control_plane, upgrade_kubezero"

  #echo "Adjust kubezero values as needed:"
  # shellcheck disable=SC2015
  #[ "$ARGOCD" == "true" ] && kubectl edit app kubezero -n argocd || kubectl edit cm kubezero-values -n kubezero

  #echo "<Return> to continue"
  #read -r

  # upgrade modules
  admin_job "apply_kubezero, apply_network"
}

control_plane_phase2() {
  # Final control plane upgrades
  admin_job "upgrade_control_plane"
}

cluster_modules() {
  echo "Applying remaining KubeZero modules..."

  admin_job "apply_policy, apply_addons, apply_storage, apply_operators, apply_cert-manager, apply_istio, apply_istio-ingress, apply_istio-private-ingress, apply_logging, apply_metrics, apply_telemetry, apply_argo"

  # Final step is to commit the new argocd kubezero app
  kubectl get app kubezero -n argocd -o yaml | yq 'del(.status) | del(.metadata) | del(.operation) | .metadata.name="kubezero" | .metadata.namespace="argocd"' | yq 'sort_keys(..)' > $ARGO_APP
}

backup() {
  # Trigger backup of upgraded cluster state
  kubectl create job --from=cronjob/kubezero-backup kubezero-backup-$KUBE_VERSION -n kube-system
  while true; do
    kubectl wait --for=condition=complete job/kubezero-backup-$KUBE_VERSION -n kube-system 2>/dev/null && kubectl delete job kubezero-backup-$KUBE_VERSION -n kube-system && break
    sleep 1
  done
}


control_plane_healthy() {
  echo "Checking control-plane is healthy..."
  kubectl rollout status ds cilium -n kube-system
  waitSystemPodsRunning
}

#####


control_plane_healthy

[ "$ARGOCD" == "true" ] && disable_argo

control_plane_phase1

control_plane_healthy

echo "Replace controller nodes first to not stall out V1.31 controllers ... <return> to continue"
read -r

cluster_modules

backup

echo "Once ALL nodes, incl. workers, ALL, are running on $KUBE_VERSION <return> to continue"
read -r

control_plane_phase2

echo "Please commit $ARGO_APP as the updated kubezero/application.yaml for your cluster."
echo "Then head over to ArgoCD for this cluster and sync all KubeZero modules to apply remaining upgrades."

echo "<Return> to continue and re-enable ArgoCD:"
read -r

[ "$ARGOCD" == "true" ] && enable_argo
