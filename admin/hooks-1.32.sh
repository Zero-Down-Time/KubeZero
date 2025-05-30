### v1.32

# All things BEFORE the first controller / control plane upgrade
pre_control_plane_upgrade_cluster() {
  if [ "$PLATFORM" != "gke" ];then
    # patch multus DS to ONLY run pods on 1.31 controllers
    kubectl patch ds kube-multus-ds -n kube-system -p '{"spec": {"template": {"spec": {"nodeSelector": {"node.kubernetes.io/kubezero.version": "v1.31.6"}}}}}' || true
  fi
}


# All things after the first controller / control plane upgrade
post_control_plane_upgrade_cluster() {
  echo
}


# All things AFTER all contollers are on the new version
pre_cluster_upgrade_final() {
  set +e

  if [ "$PLATFORM" != "gke" ];then
    # cleanup multus
    kubectl delete clusterrolebinding multus
    kubectl delete clusterrole multus
    kubectl delete serviceaccount multus -n kube-system
    kubectl delete cm multus-cni-config -n kube-system
    kubectl delete ds kube-multus-ds -n kube-system
    kubectl delete NetworkAttachmentDefinition cilium
    kubectl delete crd network-attachment-definitions.k8s.cni.cncf.io
  fi

  set -e
}


# Last call
post_cluster_upgrade_final() {
  echo
}
