{{- /* Feature gates for all control plane components */ -}}
{{- /* Issues: MemoryQoS */ -}}
{{- /* v1.28: PodAndContainerStatsFromCRI still not working */ -}}
{{- /* v1.34: MutatingAdmissionPolicy, CoordinatedLeaderElection are causing startup issues */ -}}
{{- define "kubeadm.featuregates" }}
{{- $gates := list "CustomCPUCFSQuotaPeriod" "EnvFiles" }}
{{- if eq .return "csv" }}
{{- range $key := $gates }}
{{- $key }}=true,
{{- end }}
{{- else }}
{{- range $key := $gates }}
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
