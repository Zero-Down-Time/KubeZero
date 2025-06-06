{{- define "kubezero-app.app" }}
{{- $name := regexReplaceAll "kubezero/templates/([a-z-]*)..*" .Template.Name "${1}" }}

{{- if index .Values $name "enabled" }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $name }}
  namespace: argocd
  labels:
    {{- include "kubezero-lib.labels" . | nindent 4 }}
  annotations:
    argocd.argoproj.io/compare-options: ServerSideDiff=true,IncludeMutationWebhook=true
    # argocd.argoproj.io/sync-options: Replace=true
    {{- with ( index .Values $name "annotations" ) }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if not ( index .Values $name "retain" ) }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  {{- end }}
spec:
  project: kubezero

  source:
    chart: {{ default (print "kubezero-" $name) (index .Values $name "chart") }}
    repoURL: {{ default "https://cdn.zero-downtime.net/charts" (index .Values $name "repository") }}
    targetRevision: {{ default "HEAD" ( index .Values $name "targetRevision" ) | quote }}
    helm:
      skipTests: true
      valuesObject:
        {{- toYaml (merge (omit (index .Values $name) "enabled" "namespace" "retain" "targetRevision") (fromYaml (include (print $name "-values") $ ))) | nindent 8 }}

  destination:
    server: "https://kubernetes.default.svc"
    namespace: {{ default "kube-system" ( index .Values $name "namespace" ) }}

  revisionHistoryLimit: 2
  syncPolicy:
    automated:
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
  info:
    - name: "Source:"
      value: "https://git.zero-downtime.net/ZeroDownTime/KubeZero/src/branch/release/v1.31/charts/kubezero-{{ $name }}"
{{- include (print $name "-argo") $ }}
{{- end }}

{{- end }}
