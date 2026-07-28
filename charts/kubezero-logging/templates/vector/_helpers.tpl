{{- /*
Params (dict):
  root      - the root template context ($), for .Values access
  svc       - route/index prefix, e.g. "cloudtrail", "s3-access-logs"
  idKey     - the sink's id_key value, e.g. "eventID" or "id"
*/ -}}
{{- define "kubezero-logging.vector.opensearchSink" -}}
opensearch_{{ .svc }}:
  type: elasticsearch
  inputs:
    - sink_router.{{ .svc }}
  endpoints: [{{ .root.Values.vector.opensearch.endpoint | quote }}]
  api_version: v8
  mode: bulk
  id_key: {{ .idKey }}
  bulk:
    action: index
    index: '{{ .svc }}-{{ "{{ index_suffix }}" }}'
  request:
    retry_attempts: 5
    retry_initial_backoff_secs: 3
  auth:
    strategy: basic
    user: "SECRET[opensearch.username]"
    password: "SECRET[opensearch.password]"
  tls:
    verify_certificate: false
  encoding:
    except_fields: ["index_suffix"]
  compression: gzip
  batch: { max_events: 1000, timeout_secs: 5 }
  buffer:
    type: {{ .root.Values.vector.opensearch.buffer.type }}
    {{- if eq .root.Values.vector.opensearch.buffer.type "disk" }}
    max_size: {{ .root.Values.vector.opensearch.buffer.maxSize | int64 }}
    {{- else }}
    max_events: {{ .root.Values.vector.opensearch.buffer.maxEvents }}
    {{- end }}
  healthcheck: { enabled: true }
  acknowledgements:
    enabled: true
{{- end -}}
