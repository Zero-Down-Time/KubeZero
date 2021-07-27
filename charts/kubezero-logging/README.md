# kubezero-logging

![Version: 0.7.0](https://img.shields.io/badge/Version-0.7.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.0](https://img.shields.io/badge/AppVersion-1.6.0-informational?style=flat-square)

KubeZero Umbrella Chart for complete EFK stack

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
|  | eck-operator | 1.6.0 |
|  | fluent-bit | 0.15.14 |
|  | fluentd | 0.2.6 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Changes from upstream
### ECK
- Operator mapped to controller nodes

### ES

- SSL disabled ( Todo: provide cluster certs and setup Kibana/Fluentd to use https incl. client certs )

- Installed Plugins:
  - repository-s3
  - elasticsearch-prometheus-exporter

- [Cross AZ Zone awareness](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-advanced-node-scheduling.html#k8s-availability-zone-awareness) is implemented via nodeSets

### Kibana

- increased timeout to ES to 3 minutes

### FluentD

### Fluent-bit
- support for dedot Lua filter to replace "." with "_" for all annotations and labels
- support for api audit log

## Manual tasks ATM

- install index template
- setup Kibana
- create `logstash-*` Index Pattern

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eck-operator.enabled | bool | `false` |  |
| eck-operator.installCRDs | bool | `false` |  |
| eck-operator.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| eck-operator.tolerations[0].effect | string | `"NoSchedule"` |  |
| eck-operator.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| elastic_password | string | `""` |  |
| es.nodeSets | list | `[]` |  |
| es.prometheus | bool | `false` |  |
| es.s3Snapshot.enabled | bool | `false` |  |
| es.s3Snapshot.iamrole | string | `""` |  |
| fluent-bit.config.customParsers | string | `"[PARSER]\n    Name cri-log\n    Format regex\n    Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<log>.*)$\n    Time_Key    time\n    Time_Format %Y-%m-%dT%H:%M:%S.%L%z\n"` |  |
| fluent-bit.config.filters | string | `"[FILTER]\n    Name    lua\n    Match   cri.*\n    script  /fluent-bit/scripts/kubezero.lua\n    call    reassemble_cri_logs\n\n[FILTER]\n    Name kubernetes\n    Match cri.*\n    Merge_Log On\n    Merge_Log_Key kube\n    Kube_Tag_Prefix cri.var.log.containers.\n    Keep_Log Off\n    K8S-Logging.Parser Off\n    K8S-Logging.Exclude Off\n    #Use_Kubelet true\n    #Kubelet_Port 10250\n\n{{- if index .Values \"config\" \"extraRecords\" }}\n\n[FILTER]\n    Name record_modifier\n    Match cri.*\n    {{- range $k,$v := index .Values \"config\" \"extraRecords\" }}\n    Record {{ $k }} {{ $v }}\n    {{- end }}\n{{- end }}\n\n[FILTER]\n    Name rewrite_tag\n    Match cri.*\n    Emitter_Name kube_tag_rewriter\n    Rule logtag F kube.$kubernetes['namespace_name'].$kubernetes['container_name'] false\n\n[FILTER]\n    Name    lua\n    Match   kube.*\n    script  /fluent-bit/scripts/kubezero.lua\n    call    nest_k8s_ns\n"` |  |
| fluent-bit.config.flushInterval | int | `5` |  |
| fluent-bit.config.input.memBufLimit | string | `"4MB"` |  |
| fluent-bit.config.input.refreshInterval | int | `10` |  |
| fluent-bit.config.inputs | string | `"[INPUT]\n    Name tail\n    Path /var/log/containers/*.log\n    Parser cri-log\n    Tag cri.*\n    Skip_Long_Lines On\n    DB /var/log/flb_kube.db\n    DB.Sync Normal\n    {{- with .Values.config.input }}\n    Mem_Buf_Limit {{ default \"4MB\" .memBufLimit }}\n    Refresh_Interval {{ default 10 .refreshInterval }}\n    {{- end }}\n"` |  |
| fluent-bit.config.logLevel | string | `"warn"` |  |
| fluent-bit.config.output.host | string | `"logging-fluentd"` |  |
| fluent-bit.config.output.sharedKey | string | `"cloudbender"` |  |
| fluent-bit.config.output.tls | bool | `false` |  |
| fluent-bit.config.outputs | string | `"[OUTPUT]\n    Match *\n    Name forward\n    Host {{ .Values.config.output.host }}\n    Port 24224\n    Shared_Key {{ .Values.config.output.sharedKey }}\n    tls {{ ternary \"on\" \"off\" .Values.config.output.tls }}\n    Send_options true\n    Require_ack_response true\n"` |  |
| fluent-bit.config.service | string | `"[SERVICE]\n    Flush {{ .Values.config.flushInterval }}\n    Daemon Off\n    Log_Level {{ .Values.config.logLevel }}\n    Parsers_File parsers.conf\n    Parsers_File custom_parsers.conf\n    HTTP_Server On\n    HTTP_Listen 0.0.0.0\n    HTTP_Port {{ .Values.service.port }}\n"` |  |
| fluent-bit.daemonSetVolumeMounts[0].mountPath | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumeMounts[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumeMounts[1].mountPath | string | `"/etc/machine-id"` |  |
| fluent-bit.daemonSetVolumeMounts[1].name | string | `"etcmachineid"` |  |
| fluent-bit.daemonSetVolumeMounts[1].readOnly | bool | `true` |  |
| fluent-bit.daemonSetVolumes[0].hostPath.path | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumes[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumes[1].hostPath.path | string | `"/etc/machine-id"` |  |
| fluent-bit.daemonSetVolumes[1].hostPath.type | string | `"File"` |  |
| fluent-bit.daemonSetVolumes[1].name | string | `"etcmachineid"` |  |
| fluent-bit.enabled | bool | `false` |  |
| fluent-bit.luaScripts."kubezero.lua" | string | `"local reassemble_state = {}\n\nfunction reassemble_cri_logs(tag, timestamp, record)\n   local reassemble_key = tag\n   if record.logtag == 'P' then\n      reassemble_state[reassemble_key] = reassemble_state[reassemble_key] or \"\" .. record.log\n      return -1, 0, 0\n   end\n   record.log = reassemble_state[reassemble_key] or \"\" .. (record.log or \"\")\n   reassemble_state[reassemble_key] = nil\n   return 1, timestamp, record\nend\n\nfunction nest_k8s_ns(tag, timestamp, record)\n    if not record['kubernetes']['namespace_name'] then\n        return 0, 0, 0\n    end\n    new_record = {}\n    for key, val in pairs(record) do\n        if key == 'kube' then\n            new_record[key] = {}\n            new_record[key][record['kubernetes']['namespace_name']] = record[key]\n        else\n            new_record[key] = record[key]\n        end\n    end\n    return 1, timestamp, new_record\nend\n"` |  |
| fluent-bit.resources.limits.memory | string | `"64Mi"` |  |
| fluent-bit.resources.requests.cpu | string | `"20m"` |  |
| fluent-bit.resources.requests.memory | string | `"32Mi"` |  |
| fluent-bit.serviceMonitor.enabled | bool | `false` |  |
| fluent-bit.serviceMonitor.selector.release | string | `"metrics"` |  |
| fluent-bit.tolerations[0].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| fluentd.dashboards.enabled | bool | `false` |  |
| fluentd.enabled | bool | `false` |  |
| fluentd.env[0].name | string | `"FLUENTD_CONF"` |  |
| fluentd.env[0].value | string | `"../../etc/fluent/fluent.conf"` |  |
| fluentd.env[1].name | string | `"OUTPUT_PASSWORD"` |  |
| fluentd.env[1].valueFrom.secretKeyRef.key | string | `"elastic"` |  |
| fluentd.env[1].valueFrom.secretKeyRef.name | string | `"logging-es-elastic-user"` |  |
| fluentd.fileConfigs."00_system.conf" | string | `"<system>\n  root_dir /var/log/fluentd\n  # log_level debug\n  workers 2\n</system>"` |  |
| fluentd.fileConfigs."01_sources.conf" | string | `"<source>\n  @type http\n  @label @KUBERNETES\n  port 9880\n  bind 0.0.0.0\n  keepalive_timeout 30\n</source>\n\n<source>\n  @type forward\n  @label @KUBERNETES\n  port 24224\n  bind 0.0.0.0\n  # skip_invalid_event true\n  send_keepalive_packet true\n  <security>\n    self_hostname \"#{ENV['HOSTNAME']}\"\n    shared_key {{ .Values.shared_key }}\n  </security>\n</source>"` |  |
| fluentd.fileConfigs."02_filters.conf" | string | `"<label @KUBERNETES>\n  # prevent log feedback loops eg. ES has issues etc.\n  # discard logs from our own pods\n  <match kube.logging.fluentd>\n    @type relabel\n    @label @FLUENT_LOG\n  </match>\n\n  <match **>\n    @type relabel\n    @label @DISPATCH\n  </match>\n</label>"` |  |
| fluentd.fileConfigs."04_outputs.conf" | string | `"<label @OUTPUT>\n  <match **>\n    @id out_es\n    @type elasticsearch\n    @log_level info\n    include_tag_key true\n    id_key id\n    remove_keys id\n\n    # KubeZero pipeline incl. GeoIP etc.\n    pipeline fluentd\n\n    hosts \"{{ .Values.output.host }}\"\n    port 9200\n    scheme http\n    user elastic\n    password \"#{ENV['OUTPUT_PASSWORD']}\"\n\n    log_es_400_reason\n    logstash_format true\n    reconnect_on_error true\n    reload_on_failure true\n    request_timeout 60s\n    suppress_type_name true\n    slow_flush_log_threshold 50.0\n\n    # Retry failed bulk requests\n    # https://github.com/uken/fluent-plugin-elasticsearch#unrecoverable-error-types\n    unrecoverable_error_types [\"out_of_memory_error\"]\n    bulk_message_request_threshold 2097152\n\n    <buffer>\n      @type file\n\n      flush_mode interval\n      flush_thread_count 1\n      flush_interval 30s\n\n      chunk_limit_size 4MB\n      total_limit_size 2GB\n\n      flush_at_shutdown true\n      retry_type exponential_backoff\n      retry_timeout 2h\n      overflow_action drop_oldest_chunk\n      disable_chunk_backup true\n    </buffer>\n  </match>\n</label>"` |  |
| fluentd.image.repository | string | `"fluent/fluentd-kubernetes-daemonset"` |  |
| fluentd.image.tag | string | `"v1-debian-elasticsearch"` |  |
| fluentd.istio.enabled | bool | `false` |  |
| fluentd.kind | string | `"Deployment"` |  |
| fluentd.metrics.serviceMonitor.additionalLabels.release | string | `"metrics"` |  |
| fluentd.metrics.serviceMonitor.enabled | bool | `false` |  |
| fluentd.output.host | string | `"logging-es-http"` |  |
| fluentd.replicaCount | int | `1` |  |
| fluentd.resources.limits.memory | string | `"512Mi"` |  |
| fluentd.resources.requests.cpu | string | `"200m"` |  |
| fluentd.resources.requests.memory | string | `"256Mi"` |  |
| fluentd.service.ports[0].containerPort | int | `24224` |  |
| fluentd.service.ports[0].name | string | `"tcp-forward"` |  |
| fluentd.service.ports[0].protocol | string | `"TCP"` |  |
| fluentd.service.ports[1].containerPort | int | `9880` |  |
| fluentd.service.ports[1].name | string | `"http-fluentd"` |  |
| fluentd.service.ports[1].protocol | string | `"TCP"` |  |
| fluentd.shared_key | string | `"cloudbender"` |  |
| fluentd.volumeMounts[0].mountPath | string | `"/etc/fluent"` |  |
| fluentd.volumeMounts[0].name | string | `"etcfluentd-main"` |  |
| fluentd.volumeMounts[1].mountPath | string | `"/etc/fluent/config.d/"` |  |
| fluentd.volumeMounts[1].name | string | `"etcfluentd-config"` |  |
| fluentd.volumes[0].configMap.defaultMode | int | `511` |  |
| fluentd.volumes[0].configMap.name | string | `"fluentd-main"` |  |
| fluentd.volumes[0].name | string | `"etcfluentd-main"` |  |
| fluentd.volumes[1].configMap.defaultMode | int | `511` |  |
| fluentd.volumes[1].configMap.name | string | `"fluentd-config"` |  |
| fluentd.volumes[1].name | string | `"etcfluentd-config"` |  |
| kibana.count | int | `1` |  |
| kibana.istio.enabled | bool | `false` |  |
| kibana.istio.gateway | string | `"istio-system/ingressgateway"` |  |
| kibana.istio.url | string | `""` |  |
| version | string | `"7.13.2"` |  |

## Resources:

- https://www.elastic.co/downloads/elastic-cloud-kubernetes
- https://github.com/elastic/cloud-on-k8s
- https://grafana.com/grafana/dashboards/7752
