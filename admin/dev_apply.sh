#!/bin/bash
#set -eEx
#set -o pipefail
set -x

ARTIFACTS=($(echo $1 | tr "," "\n"))
ACTION="${2:-apply}"
ARGOCD="${3:-False}"

LOCAL_DEV=1

#VERSION="latest"
KUBE_VERSION="$(kubectl version -o json | jq -r .serverVersion.gitVersion)"

WORKDIR=$(mktemp -p /tmp -d kubezero.XXX)
[ -z "$DEBUG" ] && trap 'rm -rf $WORKDIR' ERR EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/libhelm.sh
CHARTS="$(dirname $SCRIPT_DIR)/charts"

# Guess platform from current context
_auth_cmd=$(kubectl config view | yq .users[0].user.exec.command)
if [ "$_auth_cmd" == "gke-gcloud-auth-plugin" ]; then
  PLATFORM=gke
elif [ "$_auth_cmd" == "aws-iam-authenticator" ]; then
  PLATFORM=aws
else
  PLATFORM=nocloud
fi

parse_version() {
  echo $([[ $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]] && echo "${BASH_REMATCH[0]//v/}")
}

KUBE_VERSION=$(parse_version $KUBE_VERSION)

### Various hooks for modules

################
# cert-manager #
################
function cert-manager-post() {
  # If any error occurs, wait for initial webhook deployment and try again
  # see: https://cert-manager.io/docs/concepts/webhook/#webhook-connection-problems-shortly-after-cert-manager-installation

  if [ $rc -ne 0 ]; then
    wait_for "kubectl get deployment -n $namespace cert-manager-webhook"
    kubectl rollout status deployment -n $namespace cert-manager-webhook
    wait_for 'kubectl get validatingwebhookconfigurations -o yaml | grep "caBundle: LS0"'
  fi

  wait_for "kubectl get ClusterIssuer -n $namespace kubezero-local-ca-issuer"
  kubectl wait --timeout=180s --for=condition=Ready -n $namespace ClusterIssuer/kubezero-local-ca-issuer
}


###########
# ArgoCD  #
###########
function argocd-pre() {
  kubectl delete job argo-argocd-redis-secret-init -n argocd || true

  for f in $CLUSTER/secrets/argocd-*.yaml; do
    kubectl apply -f $f
  done
}


###########
# Metrics #
###########
# Cleanup patch jobs from previous runs , ArgoCD does this automatically
function metrics-pre() {
  kubectl delete jobs --field-selector status.successful=1 -n monitoring
}


### Main
get_kubezero_values $ARGOCD

# Always use embedded kubezero chart
helm template $CHARTS/kubezero -f $WORKDIR/kubezero-values.yaml --kube-version $KUBE_VERSION --name-template kubezero --version ~$KUBE_VERSION --devel --output-dir $WORKDIR

# Root KubeZero apply directly and exit
if [ ${ARTIFACTS[0]} == "kubezero" ]; then
  kubectl replace -f $WORKDIR/kubezero/templates $(field_manager $ARGOCD)
  exit $?

# "catch all" apply all enabled modules
elif [ ${ARTIFACTS[0]} == "all" ]; then
  ARTIFACTS=($(ls $WORKDIR/kubezero/templates | sed -e 's/.yaml//g'))
fi

# Delete in reverse order, continue even if errors
if [ "$ACTION" == "delete" ]; then
  set +e
  for (( idx=${#ARTIFACTS[@]}-1 ; idx>=0 ; idx-- )) ; do
    _helm delete ${ARTIFACTS[idx]} || true
  done
else
  if [ "$ACTION" == "apply" -o "$ACTION" == "crds" ]; then
    for t in ${ARTIFACTS[@]}; do
      _helm crds $t || true
    done
  fi
  for t in ${ARTIFACTS[@]}; do
    _helm apply $t || true
  done
fi
