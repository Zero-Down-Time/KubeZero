{{/* vim: set filetype=mustache: */}}

{{/* Define common labels */}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/component: middleware
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end -}}

{{/* Generate init container properties */}}
{{- define "initContainer.properties" -}}
{{- with .Values.initContainer }}
{{- if .enabled }}
enabled: {{ .enabled }}
image: {{ .image }}
{{- if .imagePullPolicy }}
imagePullPolicy: {{ .imagePullPolicy }}
{{- end }}
{{- if .resources }}
resources:
  {{ toYaml .resources | nindent 2 }}
{{- end }}
{{- if .env }}
env:
{{ toYaml .env | nindent 2 }}
{{- end }}
{{- if .command }}
command:
{{ toYaml .command | nindent 2 }}
{{- end }}
{{- if .args }}
args:
{{ toYaml .args | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Generate sidecar properties for redis-vault */}}
{{- define "redisVault.sidecar" -}}
- name: redis-vault
  image: {{ .Values.redisVault.image.repository }}:{{ .Values.redisVault.image.tag }}
  resources: {{ toYaml .Values.redisVault.resources | nindent 4 }}
  mountPath:
    - name: {{ .Values.redisReplication.name | default .Release.Name }}
      mountPath: /data
      readOnly: true
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    capabilities:
      drop: ["ALL"]
  {{- with .Values.redisVault.env }}
  env: {{ toYaml . | nindent 4 }}
  {{- end -}}
{{- end -}}
