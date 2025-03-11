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
  {{- with ( index .Values $name "annotations" ) }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if not ( index .Values $name "retain" ) }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  {{- end }}
spec:
  project: kubezero

  source:
    {{- if index .Values $name "chart" }}
    chart: {{ index .Values $name "chart" }}
    {{- else }}
    chart: kubezero-{{ $name }}
    {{- end }}
    repoURL: {{ .Values.kubezero.repoURL }}
    targetRevision: {{ default .Values.kubezero.targetRevision ( index .Values $name "targetRevision" ) | quote }}
    helm:
      skipTests: true
      valuesObject:
        {{- include (print $name "-values") $ | nindent 8 }}

  destination:
    server: {{ .Values.kubezero.server }}
    namespace: {{ default "kube-system" ( index .Values $name "namespace" ) }}

  revisionHistoryLimit: 2
  syncPolicy:
    automated:
      prune: true
    syncOptions:
      - ServerSideApply=true
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
{{- include (print $name "-argo") $ }}
{{- end }}

{{- end }}
