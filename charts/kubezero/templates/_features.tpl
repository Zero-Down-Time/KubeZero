{{- define "kubezero.grafana.enabled" -}}
{{- if ne .Values.global.platform "gke" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{- define "kubezero.prometheus.enabled" -}}
{{- if ne .Values.global.platform "gke" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
