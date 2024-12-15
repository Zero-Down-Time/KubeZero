{{- /*
maps pods to the kube control-plane
*/ -}}
{{- define "kubezero-lib.control-plane" -}}
nodeSelector:
  node-role.kubernetes.io/control-plane: ""
tolerations:
- key: node-role.kubernetes.io/control-plane
  effect: NoSchedule
{{- end -}}
