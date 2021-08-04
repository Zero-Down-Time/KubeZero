#!/bin/bash
set -ex

ACTION=$1
ARTIFACTS=($(echo $2 | tr "," "\n"))
CLUSTER=$3
LOCATION=${4:-""}

API_VERSIONS="-a monitoring.coreos.com/v1"

DEPLOY_DIR=$( dirname $( realpath $0 ))
which yq || { echo "yq not found!"; exit 1; }
which helm || { echo "helm not found!"; exit 1; }
helm_version=$(helm version --short)
echo $helm_version | grep -qe "^v3.[3-9]" || { echo "Helm version >= 3.3 required!"; exit 1; }

TMPDIR=$(mktemp -d kubezero.XXX)
[ -z "$DEBUG" ] && trap 'rm -rf $TMPDIR' ERR EXIT

# First lets generate kubezero.yaml
# Add all yaml files in $CLUSTER
VALUES="$(find $CLUSTER -name '*.yaml' | tr '\n' ',')"
helm template $DEPLOY_DIR -f ${VALUES%%,} --set argo=false > $TMPDIR/kubezero.yaml

# Resolve all the all enabled artifacts in order of their appearance
if [ ${ARTIFACTS[0]} == "all" ]; then
  ARTIFACTS=($(yq r -p p $TMPDIR/kubezero.yaml "*.enabled" | awk -F "." '{print $1}'))
fi

# Update only if we use upstream
if [ -z "$LOCATION" ]; then
  helm repo add kubezero https://zero-down-time.github.io/kubezero
  helm repo update
fi

# Waits for max 300s and retries
function wait_for() {
  local TRIES=0
  while true; do
    eval " $@" && break
    [ $TRIES -eq 100 ] && return 1
    let TRIES=$TRIES+1
    sleep 3
  done
}


function chart_location() {
  if [ -z "$LOCATION" ]; then
    echo "$1 --repo https://zero-down-time.github.io/kubezero"
  else
    echo "$LOCATION/$1"
  fi
}


# make sure namespace exists prior to calling helm as the create-namespace options doesn't work
function create_ns() {
  local namespace=$1
  if [ "$namespace" != "kube-system" ]; then
    kubectl get ns $namespace || kubectl create ns $namespace
  fi
}


# delete non kube-system ns
function delete_ns() {
  local namespace=$1
  [ "$namespace" != "kube-system" ] && kubectl delete ns $namespace
}


# Extract crds via helm calls and apply delta=crds only
function _crds() {
  helm template $(chart_location $chart) --namespace $namespace --name-template $release --skip-crds --set ${release}.installCRDs=false -f $TMPDIR/values.yaml > $TMPDIR/helm-no-crds.yaml
  helm template $(chart_location $chart) --namespace $namespace --name-template $release --include-crds --set ${release}.installCRDs=true -f $TMPDIR/values.yaml > $TMPDIR/helm-crds.yaml
  diff -e $TMPDIR/helm-no-crds.yaml $TMPDIR/helm-crds.yaml | head -n-1 | tail -n+2 > $TMPDIR/crds.yaml
  [ -s $TMPDIR/crds.yaml ] && kubectl apply -f $TMPDIR/crds.yaml
}


# helm template | kubectl apply -f -
# confine to one namespace if possible
function apply(){
  helm template $(chart_location $chart) --namespace $namespace --name-template $release --skip-crds -f $TMPDIR/values.yaml $API_VERSIONS $@ > $TMPDIR/helm.yaml

  # If resources are out of the single $namespace, apply without restrictions
  nr_ns=$(grep -e '^  namespace:' $TMPDIR/helm.yaml  | sed "s/\"//g" | sort | uniq | wc -l)
  if [ $nr_ns -gt 1 ]; then
    kubectl $action -f $TMPDIR/helm.yaml && rc=$? || rc=$?
  else
    kubectl $action --namespace $namespace -f $TMPDIR/helm.yaml && rc=$? || rc=$?
  fi
}


function _helm() {
  local action=$1

  local chart="kubezero-$2"
  local release=$2
  local namespace=$(get_namespace $2)

  if [ $action == "crds" ]; then
    declare -F ${release}-crds && ${release}-crds
    declare -F ${release}-crds || _crds

  elif [ $action == "apply" ]; then
    # namespace must exist prior to apply
    create_ns $namespace

    # Optional pre hook
    declare -F ${release}-pre && ${release}-pre

    apply

    # Optional post hook
    declare -F ${release}-post && ${release}-post

  elif [ $action == "delete" ]; then
    apply

    # Delete dedicated namespace if not kube-system
    delete_ns $namespace
  fi

  return 0
}


function is_enabled() {
  local chart=$1
  local enabled=$(yq r $TMPDIR/kubezero.yaml ${chart}.enabled)

  if [ "$enabled" == "true" ]; then
    yq r $TMPDIR/kubezero.yaml ${chart}.values > $TMPDIR/values.yaml
    return 0
  fi
  return 1
}


function has_crds() {
  local chart=$1
  local enabled=$(yq r $TMPDIR/kubezero.yaml ${chart}.crds)

  [ "$enabled" == "true" ] && return 0
  return 1
}


function get_namespace() {
  local namespace=$(yq r $TMPDIR/kubezero.yaml ${1}.namespace)
  [ -z "$namespace" ] && echo "kube-system" || echo $namespace
}


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
    apply
  fi

  wait_for "kubectl get ClusterIssuer -n $namespace kubezero-local-ca-issuer"
  kubectl wait --timeout=180s --for=condition=Ready -n $namespace ClusterIssuer/kubezero-local-ca-issuer
}


########
# Kiam #
########
function kiam-pre() {
  # Certs only first
  apply --set kiam.enabled=false
  kubectl wait --timeout=120s --for=condition=Ready -n kube-system Certificate/kiam-server
}

function kiam-post() {
  wait_for 'kubectl get daemonset -n kube-system kiam-agent'
  kubectl rollout status daemonset -n kube-system kiam-agent
}


###########
# Metrics #
###########
# Cleanup patch jobs from previous runs , ArgoCD does this automatically
function metrics-pre() {
  kubectl delete jobs --field-selector status.successful=1 -n monitoring
}


## MAIN ##
if [ $1 == "deploy" ]; then
  for t in ${ARTIFACTS[@]}; do
    is_enabled $t && _helm apply $t || true
  done

# If artifact enabled and has crds install
elif [ $1 == "crds" ]; then
  for t in ${ARTIFACTS[@]}; do
    is_enabled $t && has_crds $t && _helm crds $t || true
  done

# Delete in reverse order, continue even if errors
elif [ $1 == "delete" ]; then
  set +e
  for (( idx=${#ARTIFACTS[@]}-1 ; idx>=0 ; idx-- )) ; do
    is_enabled ${ARTIFACTS[idx]} && _helm delete ${ARTIFACTS[idx]} || true
  done
fi
