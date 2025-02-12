### v1.31

# All things BEFORE the first controller / control plane upgrade
pre_control_plane_upgrade_cluster() {
  # add kubezero version label to existing controller nodes for aws-iam migration
  for n in $(kubectl get nodes -l "node-role.kubernetes.io/control-plane=" | grep v1.30 | awk {'print $1}'); do
    kubectl label node $n 'node.kubernetes.io/kubezero.version=v1.30.6' || true
  done

  # patch aws-iam-authentiator DS to NOT run pods on 1.31 controllers
  kubectl patch ds aws-iam-authentiator -p '{"spec": {"template": {"spec": {"nodeSelector": {"node.kubernetes.io/kubezero.version": "v1.30.6"}}}}}' || true
}


# All things after the first controller / control plane upgrade
post_control_plane_upgrade_cluster() {
  echo
}


# All things AFTER all contollers are on the new version
pre_cluster_upgrade_final() {

  if [ "$PLATFORM" == "aws" ];then
    # cleanup aws-iam-authentiator
    kubectl delete clusterrolebinding aws-iam-authentiator || true
    kubectl delete clusterrole aws-iam-authentiator || true
    kubectl delete serviceaccount aws-iam-authentiator -n kube-system || true
    kubectl delete cm aws-iam-authentiator -n kube-system || true
    kubectl delete ds aws-iam-authentiator -n kube-system || true
    kubectl delete IAMIdentityMapping kubezero-worker-nodes || true
    kubectl delete IAMIdentityMapping kubernetes-admin || true
    kubectl delete crd iamidentitymappings.iamauthenticator.k8s.aws || true

    kubectl delete secret aws-iam-certs -n kube-system || true
  fi
}


# Last call
post_cluster_upgrade_final() {
  echo
}
