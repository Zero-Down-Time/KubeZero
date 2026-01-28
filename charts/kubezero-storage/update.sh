#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

GARAGE_VERSION=$(yq eval '.dependencies[] | select(.name=="garage") | .version' Chart.yaml)

# Garage
rm -rf charts/garage
git clone https://git.deuxfleurs.fr/Deuxfleurs/garage --depth 1 --branch v${GARAGE_VERSION}
mv garage/script/helm/garage charts && rm -rf garage
# make helm chart version match appVersion
yq -i ".version=\"$GARAGE_VERSION\"" charts/garage/Chart.yaml
cp -r charts/garage charts/garage.orig
[ -r garage.patch ] && patch -p0 -i garage.patch --no-backup-if-mismatch

#login_ecr_public
update_helm

patch_chart lvm-localpv

patch_chart gemini

# snapshotter
_f="templates/snapshot-controller/rbac.yaml"
echo "{{- if .Values.snapshotController.enabled }}" >$_f
curl -L -s https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml >>$_f
echo "{{- end }}" >>$_f

# our controller.yaml is based on:
# https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml

for crd in volumesnapshotclasses volumesnapshotcontents volumesnapshots; do
  _f="templates/snapshot-controller/${crd}-crd.yaml"
  echo "{{- if .Values.snapshotController.enabled }}" >$_f
  curl -L -s https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_${crd}.yaml >>$_f
  echo "{{- end }}" >>$_f
done

# k8up - CRDs
VERSION=$(yq eval '.dependencies[] | select(.name=="k8up") | .version' Chart.yaml)

_f="templates/k8up/crds.yaml"
echo "{{- if .Values.k8up.enabled }}" >$_f
curl -L -s https://github.com/k8up-io/k8up/releases/download/k8up-${VERSION}/k8up-crd.yaml >>$_f
echo "{{- end }}" >>$_f

# Metrics
cd jsonnet
make render

update_docs
