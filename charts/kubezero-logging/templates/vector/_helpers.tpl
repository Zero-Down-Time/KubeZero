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
  api_version: v7
  mode: bulk
  id_key: {{ .idKey }}
  bulk:
    action: index
    index: '{{ .svc }}-{{ "{{ index_suffix }}" }}'
  auth:
    strategy: basic
    user: "SECRET[opensearch.username]"
    password: "SECRET[opensearch.password]"
  tls:
    verify_certificate: false
  encoding:
    except_fields: ["index_suffix"]
  compression: gzip
  batch: { max_events: 2000, timeout_secs: 5 }
  buffer:
    type: disk
    max_size: {{ .root.Values.vector.opensearch.buffer.maxSize | int64 }}
    when_full: {{ .root.Values.vector.opensearch.buffer.whenFull }}
  healthcheck: { enabled: true }
  acknowledgements:
    enabled: true
{{- end -}}
