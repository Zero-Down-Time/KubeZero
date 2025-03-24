# ensure we have a basic kubezero secret for cluster bootstrap and defaults
kubectl get secret kubezero-secrets -n kubezero && rc=$? || rc=$?

if [ $rc != 0 ]; then
  kubectl create secret generic kubezero-secrets -n kubezero \
    --from-literal=argo-cd.adminPassword="geheim" \
    --from-literal=argo-cd.kubezero.sshPrivateKey="--GEHEIM---"
fi
