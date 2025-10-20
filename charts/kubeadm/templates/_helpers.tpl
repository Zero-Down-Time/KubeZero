{{- /* Feature gates for all control plane components */ -}}
{{- /* Issues: MemoryQoS */ -}}
{{- /* DisableAllocatorDualWrite for now until we restrict IP ranges */ -}}
{{- /* v1.28: PodAndContainerStatsFromCRI still not working */ -}}
{{- define "kubeadm.featuregates" }}
{{- $gates := list "CustomCPUCFSQuotaPeriod" "VolumeAttributesClass" "MutatingAdmissionPolicy" "ListFromCacheSnapshot" "DisableAllocatorDualWrite"}}
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
