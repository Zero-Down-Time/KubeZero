#!/bin/bash
#set -eEx
#set -o pipefail
set -x

ARTIFACTS=($(echo $1 | tr "," "\n"))
ACTION="${2:-apply}"

LOCAL_DEV=1

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

### Main
ARGOCD=$(argo_used)
get_kubezero_values $ARGOCD

# Always use embedded kubezero chart
helm template $CHARTS/kubezero -f $WORKDIR/kubezero-values.yaml --kube-version $KUBE_VERSION --name-template kubezero --version ~$KUBE_VERSION --devel --output-dir $WORKDIR

# Root KubeZero apply directly and exit
if [ ${ARTIFACTS[0]} == "kubezero" ]; then
  [ -f $CHARTS/kubezero/hooks.d/pre-install.sh ] && . $CHARTS/kubezero/hooks.d/pre-install.sh
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
    # if only crds we are done here
    [ "$ACTION" == "crds" ] && exit 0
  fi
  for t in ${ARTIFACTS[@]}; do
    _helm $ACTION $t || true
  done
fi
