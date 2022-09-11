#!/bin/bash

# Simulate well-known CRDs being available
API_VERSIONS="-a monitoring.coreos.com/v1 -a snapshot.storage.k8s.io/v1"

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
  echo "$1 --repo https://cdn.zero-downtime.net/charts"
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
  helm template $(chart_location $chart) -n $namespace --name-template $module $targetRevision --skip-crds --set ${module}.installCRDs=false -f $WORKDIR/values.yaml $API_VERSIONS --kube-version $KUBE_VERSION > $WORKDIR/helm-no-crds.yaml
  helm template $(chart_location $chart) -n $namespace --name-template $module $targetRevision --include-crds --set ${module}.installCRDs=true -f $WORKDIR/values.yaml $API_VERSIONS --kube-version $KUBE_VERSION > $WORKDIR/helm-crds.yaml
  diff -e $WORKDIR/helm-no-crds.yaml $WORKDIR/helm-crds.yaml | head -n-1 | tail -n+2 > $WORKDIR/crds.yaml

  # Only apply if there are actually any crds
  if [ -s $WORKDIR/crds.yaml ]; then
    kubectl apply -f $WORKDIR/crds.yaml --server-side
  fi
}


# helm template | kubectl apply -f -
# confine to one namespace if possible
function apply() {
  helm template $(chart_location $chart) -n $namespace --name-template $module $targetRevision --skip-crds -f $WORKDIR/values.yaml $API_VERSIONS --kube-version $KUBE_VERSION $@ \
    | python3 -c '
#!/usr/bin/python3
import yaml
import sys

for manifest in yaml.safe_load_all(sys.stdin):
    if manifest:
        if "metadata" in manifest and "namespace" not in manifest["metadata"]:
            manifest["metadata"]["namespace"] = sys.argv[1]
        print("---")
        print(yaml.dump(manifest))' $namespace > $WORKDIR/helm.yaml

  kubectl $action -f $WORKDIR/helm.yaml && rc=$? || rc=$?
}


function _helm() {
  local action=$1
  local module=$2

  local chart="$(yq eval '.spec.source.chart' $WORKDIR/kubezero/templates/${module}.yaml)"
  local namespace="$(yq eval '.spec.destination.namespace' $WORKDIR/kubezero/templates/${module}.yaml)"

  targetRevision=""
  _version="$(yq eval '.spec.source.targetRevision' $WORKDIR/kubezero/templates/${module}.yaml)"

  [ -n "$_version" ] && targetRevision="--version $_version"

  yq eval '.spec.source.helm.values' $WORKDIR/kubezero/templates/${module}.yaml > $WORKDIR/values.yaml

  if [ $action == "crds" ]; then
    # Allow custom CRD handling
    declare -F ${module}-crds && ${module}-crds || _crds

  elif [ $action == "apply" ]; then
    # namespace must exist prior to apply
    create_ns $namespace

    # Optional pre hook
    declare -F ${module}-pre && ${module}-pre

    apply

    # Optional post hook
    declare -F ${module}-post && ${module}-post

  elif [ $action == "delete" ]; then
    apply

    # Delete dedicated namespace if not kube-system
    [ -n "$DELETE_NS" ] && delete_ns $namespace
  fi

  return 0
}
