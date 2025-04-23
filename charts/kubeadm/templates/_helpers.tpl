{{- /* Feature gates for all control plane components */ -}}
{{- /* Issues: MemoryQoS */ -}}
{{- /* v1.28: PodAndContainerStatsFromCRI still not working */ -}}
{{- /* v1.32: not required? working ? "DisableNodeKubeProxyVersion" "CoordinatedLeaderElection" */ -}}
{{- define "kubeadm.featuregates" }}
{{- $gates := list "CustomCPUCFSQuotaPeriod" "VolumeAttributesClass" "MutatingAdmissionPolicy" }}
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
