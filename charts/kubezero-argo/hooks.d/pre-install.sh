#!/bin/sh

# Bootstrap kubezero-git-sync app if it doenst exist
kubectl get application kubezero-git-sync -n argocd && rc=$? || rc=$?

[ $rc != 0 ] && yq -i '.argo-cd.kubezero.bootstrap=true' values.yaml
