#!/bin/bash

# Simulate well-known CRDs being available
API_VERSIONS="-a monitoring.coreos.com/v1 -a snapshot.storage.k8s.io/v1 -a policy/v1/PodDisruptionBudget -a apiregistration.k8s.io/v1"

export HELM_SECRETS_BACKEND="vals"

LOCAL_DEV=${LOCAL_DEV:-""}

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
  if [ -n "$LOCAL_DEV" ]; then
    echo $CHARTS/$1
  else
    echo "$1 --repo https://cdn.zero-downtime.net/charts"
  fi
}


function argo_used() {
  kubectl get application kubezero -n argocd >/dev/null \
    && echo "True" || echo "False"
}


# get kubezero-values from ArgoCD if available or use in-cluster CM
function get_kubezero_values() {
  local argo=${1:-"False"}

  if [ "$argo" == "True" ]; then
    kubectl get application kubezero -n argocd -o yaml | yq .spec.source.helm.valuesObject > ${WORKDIR}/kubezero-values.yaml
  else
    kubectl get configmap kubezero-values -n kubezero -o yaml | yq '.data."values.yaml"' > ${WORKDIR}/kubezero-values.yaml
  fi
}


# Update kubezero-values CM
function update_kubezero_cm() {
  kubectl get application kubezero -n argocd -o yaml | yq .spec.source.helm.valuesObject > ${WORKDIR}/kubezero-values.yaml

  kubectl get cm -n kubezero kubezero-values -o=yaml | \
    yq e '.data."values.yaml" |= load_str("/tmp/kubezero/kubezero-values.yaml")' | \
    kubectl apply --server-side --force-conflicts -f -
}


function disable_argo() {
  cat > _argoapp_patch.yaml <<EOF
spec:
  syncWindows:
    - kind: deny
      schedule: '0 * * * *'
      duration: 24h
      namespaces:
      - '*'
EOF
  kubectl patch appproject kubezero -n argocd --patch-file _argoapp_patch.yaml --type=merge && rm _argoapp_patch.yaml
  echo "Enabled service window for ArgoCD project kubezero"
}


function enable_argo() {
  kubectl patch appproject kubezero -n argocd --type json -p='[{"op": "remove", "path": "/spec/syncWindows"}]' || true
  echo "Removed service window for ArgoCD project kubezero"
}


function cntFailedPods() {
  NS=$1

  NR=$(kubectl get pods -n $NS --field-selector="status.phase!=Succeeded,status.phase!=Running" -o custom-columns="POD:metadata.name" -o json | jq '.items | length')
  echo $NR
}


function waitSystemPodsRunning() {
  while true; do
    [ "$(cntFailedPods kube-system)" -eq 0 ] && break
    sleep 3
  done
}

function argo_app_synced() {
  APP=$1

  # Ensure we are synced otherwise bail out
  status=$(kubectl get application $APP -n argocd -o yaml | yq .status.sync.status)
  if [ "$status" != "Synced" ]; then
    echo "ArgoCD Application $APP not 'Synced'!"
    return 1
  fi

  return 0
}


# make sure namespace exists prior to calling helm as the create-namespace options doesn't work
function create_ns() {
  local namespace=$1
  if [ "$namespace" != "kube-system" ]; then
    kubectl get ns $namespace > /dev/null || kubectl create ns $namespace
  fi
}


# delete non kube-system ns
function delete_ns() {
  local namespace=$1
  [ "$namespace" != "kube-system" ] && kubectl delete ns $namespace
}


# Extract crds via helm calls
function _crds() {
  helm secrets --evaluate-templates template $(chart_location $chart) -n $namespace --name-template $module $targetRevision --include-crds -f $WORKDIR/values.yaml $API_VERSIONS --kube-version $KUBE_VERSION $@ | python3 -c '
#!/usr/bin/python3
import yaml
import sys

yaml.add_multi_constructor("tag:yaml.org,2002:value", lambda loader, suffix, node: None, Loader=yaml.SafeLoader)

for manifest in yaml.safe_load_all(sys.stdin):
    if manifest:
        if "kind" in manifest and manifest["kind"] == "CustomResourceDefinition":
          print("---")
          print(yaml.dump(manifest))' > $WORKDIR/crds.yaml

  # Only apply if there are actually any crds
  if [ -s $WORKDIR/crds.yaml ]; then
    [ -n "$DEBUG" ] && cat $WORKDIR/crds.yaml
    kubectl apply -f $WORKDIR/crds.yaml --server-side --force-conflicts
  fi
}


# helm template | kubectl apply -f -
# confine to one namespace if possible
function render() {
  helm secrets --evaluate-templates template $(chart_location $chart) -n $namespace --name-template $module $targetRevision --skip-crds -f $WORKDIR/values.yaml $API_VERSIONS --kube-version $KUBE_VERSION $@ \
    | python3 -c '
#!/usr/bin/python3
import yaml
import sys

yaml.add_multi_constructor("tag:yaml.org,2002:value", lambda loader, suffix, node: None, Loader=yaml.SafeLoader)

for manifest in yaml.safe_load_all(sys.stdin):
    if manifest:
        if "kind" in manifest and manifest["kind"] == "CustomResourceDefinition":
          continue
        if "metadata" in manifest and "namespace" not in manifest["metadata"]:
            manifest["metadata"]["namespace"] = sys.argv[1]
        print("---")
        print(yaml.dump(manifest))' $namespace > $WORKDIR/helm.yaml
}


function _helm() {
  local action=$1
  local module=$2

  # check if module is even enabled and return if not
  [ ! -f $WORKDIR/kubezero/templates/${module}.yaml ] && { echo "Module $module disabled. No-op."; return 0; }

  local chart="$(yq eval '.spec.source.chart' $WORKDIR/kubezero/templates/${module}.yaml)"
  local namespace="$(yq eval '.spec.destination.namespace' $WORKDIR/kubezero/templates/${module}.yaml)"

  targetRevision=""
  if [ -z "$LOCAL_DEV" ]; then
    _version="$(yq eval '.spec.source.targetRevision' $WORKDIR/kubezero/templates/${module}.yaml)"
    [ -n "$_version" ] && targetRevision="--version $_version"
  fi

  yq eval '.spec.source.helm.valuesObject' $WORKDIR/kubezero/templates/${module}.yaml > $WORKDIR/values.yaml

  if [ $action == "crds" ]; then
    # Allow custom CRD handling
    declare -F ${module}-crds && ${module}-crds || _crds

  elif [ $action == "apply" ]; then
    echo "using values to $action of module $module: "
    cat $WORKDIR/values.yaml

    # namespace must exist prior to apply
    create_ns $namespace

    # Optional pre hook
    declare -F ${module}-pre && ${module}-pre

    render
    kubectl $action -f $WORKDIR/helm.yaml --server-side --force-conflicts && rc=$? || rc=$?

    # Optional post hook
    declare -F ${module}-post && ${module}-post

  elif [ $action == "delete" ]; then
    render
    kubectl $action -f $WORKDIR/helm.yaml && rc=$? || rc=$?

    # Delete dedicated namespace if not kube-system
    [ -n "$DELETE_NS" ] && delete_ns $namespace
  fi

  return 0
}

function all_nodes_upgrade() {
  CMD="$1"

  echo "Deploy all node upgrade daemonSet(busybox)"
  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kubezero-all-nodes-upgrade
  namespace: kube-system
  labels:
    app: kubezero-upgrade
spec:
  selector:
    matchLabels:
      name: kubezero-all-nodes-upgrade
  template:
    metadata:
      labels:
        name: kubezero-all-nodes-upgrade
    spec:
      hostNetwork: true
      hostIPC: true
      hostPID: true
      tolerations:
      - operator: Exists
      initContainers:
      - name: node-upgrade
        image: busybox
        command: ["/bin/sh"]
        args: ["-x", "-c", "$CMD" ]
        volumeMounts:
        - name: host
          mountPath: /host
        - name: hostproc
          mountPath: /hostproc
        securityContext:
          privileged: true
          capabilities:
            add: ["SYS_ADMIN"]
      containers:
      - name: node-upgrade-wait
        image: busybox
        command: ["sleep", "3600"]
      volumes:
      - name: host
        hostPath:
          path: /
          type: Directory
      - name: hostproc
        hostPath:
          path: /proc
          type: Directory
EOF

  kubectl rollout status daemonset -n kube-system kubezero-all-nodes-upgrade --timeout 300s
  kubectl delete ds kubezero-all-nodes-upgrade -n kube-system
}


function control_plane_upgrade() {
  TASKS="$1"

  [ -z "$KUBE_VERSION" ] && KUBE_VERSION="latest"

  echo "Deploy cluster admin task: $TASKS"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kubezero-upgrade
  namespace: kube-system
  labels:
    app: kubezero-upgrade
spec:
  hostNetwork: true
  hostIPC: true
  hostPID: true
  containers:
  - name: kubezero-admin
    image: public.ecr.aws/zero-downtime/kubezero-admin:${KUBE_VERSION}
    imagePullPolicy: Always
    command: ["kubezero.sh"]
    args: [$TASKS]
    env:
    - name: DEBUG
      value: "$DEBUG"
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    volumeMounts:
    - name: host
      mountPath: /host
    - name: workdir
      mountPath: /tmp
    securityContext:
      capabilities:
        add: ["SYS_CHROOT"]
  volumes:
  - name: host
    hostPath:
      path: /
      type: Directory
  - name: workdir
    emptyDir: {}
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
  tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
  restartPolicy: Never
EOF

  kubectl wait pod kubezero-upgrade -n kube-system --timeout 120s --for=condition=initialized 2>/dev/null
  while true; do
    kubectl logs kubezero-upgrade -n kube-system -f 2>/dev/null && break
    sleep 3
  done
  kubectl delete pod kubezero-upgrade -n kube-system
}
