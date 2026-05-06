{{- /* Feature gates for all control plane components */ -}}
{{- /* v1.23: PodAndContainerStatsFromCRI still alpha */ -}}
{{- /* v1.36: MemoryQoS */ -}}
{{- /* v1.34: CoordinatedLeaderElection higher load, wait */ -}}
{{- define "kubeadm.featuregates" }}
{{- if eq .return "csv" }}
{{- range $key := .gates }}
{{- $key }}=true,
{{- end }}
{{- else }}
{{- range $key := .gates }}
{{ $key }}: true
{{- end }}
{{- end }}
{{- end }}


{{- /* Etcd default initial cluster */ -}}
{{- define "kubeadm.etcd.initialCluster" -}}
{{- if .initialCluster -}}
{{ .initialCluster }}
{{- else -}}
{{ .nodeName }}=https://{{ .nodeName }}:2380
{{- end -}}
{{- end -}}
