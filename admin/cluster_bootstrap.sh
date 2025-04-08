#!/bin/bash
set -eEx
set -o pipefail
set -x

VALUES=$1

WORKDIR=$(mktemp -p /tmp -d kubezero.XXX)
[ -z "$DEBUG" ] && trap 'rm -rf $WORKDIR' ERR EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/libhelm.sh
CHARTS="$(dirname $SCRIPT_DIR)/charts"

KUBE_VERSION="$(get_kube_version)"
PLATFORM="$(get_kubezero_platform)"

if [ -z "$KUBE_VERSION" ]; then
  echo "Cannot contact cluster, cannot parse version!"
  exit 1
fi


# Upload values into kubezero-values
kubectl create ns kubezero || true
kubectl create cm -n kubezero kubezero-values \
    --from-file values.yaml=$VALUES || \
    kubectl get cm -n kubezero kubezero-values -o=yaml | \
    yq e ".data.\"values.yaml\" |= load_str($1)" | \
    kubectl replace -f -

### Main
get_kubezero_values $ARGOCD

# Always use embedded kubezero chart
helm template $CHARTS/kubezero -f $WORKDIR/kubezero-values.yaml --kube-version $KUBE_VERSION --name-template kubezero --version ~$KUBE_VERSION --devel --output-dir $WORKDIR

ARTIFACTS=(network addons cert-manager storage argo)

for t in ${ARTIFACTS[@]}; do
  _helm crds $t || true
  _helm apply $t || true
done
