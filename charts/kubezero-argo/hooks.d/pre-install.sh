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

# GitSync privateKey
GITKEY=$(get_kubezero_secret argo-cd.kubezero.sshPrivateKey)
if [ -z "$GITKEY" ]; then
  set_kubezero_secret argo-cd.kubezero.sshPrivateKey "Insert ssh Private Key from your git server"
fi
