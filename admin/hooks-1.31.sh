### v1.31

# All things BEFORE the first controller / control plane upgrade
pre_control_plane_upgrade_cluster() {
  # add kubezero version label to existing controller nodes for aws-iam migration
  for n in $(kubectl get nodes -l "node-role.kubernetes.io/control-plane=" | grep v1.30 | awk {'print $1}'); do
    kubectl label node $n 'node.kubernetes.io/kubezero.version=v1.30.6' || true
  done

  # patch aws-iam-authenticator DS to NOT run pods on 1.31 controllers
  kubectl patch ds aws-iam-authenticator -n kube-system -p '{"spec": {"template": {"spec": {"nodeSelector": {"node.kubernetes.io/kubezero.version": "v1.30.6"}}}}}' || true
}


# All things after the first controller / control plane upgrade
post_control_plane_upgrade_cluster() {
  # delete previous root app controlled by kubezero module
  kubectl delete application kubezero-git-sync -n argocd || true
  kubectl delete appproject kubezero -n argocd || true
}


# All things AFTER all contollers are on the new version
pre_cluster_upgrade_final() {
  set +e

  if [ "$PLATFORM" == "aws" ];then
    # cleanup aws-iam-authenticator
    kubectl delete clusterrolebinding aws-iam-authenticator
    kubectl delete clusterrole aws-iam-authenticator
    kubectl delete serviceaccount aws-iam-authenticator -n kube-system
    kubectl delete cm aws-iam-authenticator -n kube-system
    kubectl delete ds aws-iam-authenticator -n kube-system
    kubectl delete IAMIdentityMapping kubezero-worker-nodes
    kubectl delete IAMIdentityMapping kubernetes-admin
    kubectl delete crd iamidentitymappings.iamauthenticator.k8s.aws
    kubectl delete secret aws-iam-certs -n kube-system
  fi

  # Remove any helm hook related resources
  kubectl delete rolebinding argo-argocd-redis-secret-init -n argocd
  kubectl delete sa argo-argocd-redis-secret-init -n argocd
  kubectl delete role argo-argocd-redis-secret-init -n argocd
  kubectl delete job argo-argocd-redis-secret-init -n argocd

  set -e
}


# Last call
post_cluster_upgrade_final() {
  echo
}
