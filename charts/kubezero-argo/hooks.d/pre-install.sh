# Bootstrap kubezero-git-sync app only if it doesnt exist yet
kubectl get application kubezero-git-sync -n argocd || \
  yq -i '.argo-cd.kubezero.bootstrap=true' $WORKDIR/values.yaml

# Ensure we have an adminPassword or migrate existing one
PW=$(get_kubezero_secret argo-cd.adminPassword)
if [ -z "$PW" ]; then
  # Check for existing password in actual secret
  NEW_PW=$(get_secret_val argocd argocd-secret "admin.password")

  if [ -z "$NEW_PW" ];then
    ARGO_PWD=$(date +%s | sha256sum | base64 | head -c 12 ; echo)
    NEW_PW=$(htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/')

    set_kubezero_secret argo-cd.adminPasswordClear $ARGO_PWD
  fi

  set_kubezero_secret argo-cd.adminPassword "$NEW_PW"
fi

# Redis secret
kubectl get secret argocd-redis -n argocd || kubectl create secret generic argocd-redis -n argocd \
    --from-literal=auth=$(date +%s | sha256sum | base64 | head -c 16 ; echo)

# required keys in kubezero-secrets, as --ignore-missing-values in helm-secrets doesnt work with vals ;-(
ensure_kubezero_secret_key argo-cd.kubezero.username argo-cd.kubezero.password argo-cd.kubezero.sshPrivateKey
