# Remove initializedOnce marker to force plugins install
kubectl wait --for=condition=Ready pod/jenkins-0 -n $namespace --timeout=300s &&
  kubectl exec -n $namespace -c jenkins jenkins-0 -- rm -f /var/jenkins_home/initialization-completed
