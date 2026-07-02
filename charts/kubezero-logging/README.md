# kubezero-logging

![Version: 0.9.0](https://img.shields.io/badge/Version-0.9.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Logging module

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.34.0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://fluent.github.io/helm-charts | fluent-bit | 0.47.10 |
| https://fluent.github.io/helm-charts | fluentd | 0.5.2 |
| https://helm.vector.dev | vector | 0.52.0 |
| https://helm.vector.dev | vector-agent(vector) | 0.52.0 |
| https://opensearch-project.github.io/helm-charts/ | opensearch | 3.6.0 |
| https://opensearch-project.github.io/helm-charts/ | opensearch-dashboards | 3.6.0 |

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
| elastic_password | string | `""` |  |
| es.nodeSets | list | `[]` |  |
| es.prometheus | bool | `false` |  |
| es.s3Snapshot.enabled | bool | `false` |  |
| es.s3Snapshot.iamrole | string | `""` |  |
| fluent-bit.config.customParsers | string | `"[PARSER]\n    Name cri-log\n    Format regex\n    Regex ^(?<time>.+) (?<stream>stdout|stderr) (?<logtag>F|P) (?<log>.*)$\n    Time_Key    time\n    Time_Format %Y-%m-%dT%H:%M:%S.%L%z\n"` |  |
| fluent-bit.config.filters | string | `"[FILTER]\n    Name parser\n    Match cri.*\n    Parser cri-log\n    Key_Name log\n\n[FILTER]\n    Name kubernetes\n    Match cri.*\n    Merge_Log On\n    Merge_Log_Key kube\n    Kube_Tag_Prefix cri.var.log.containers.\n    Keep_Log Off\n    K8S-Logging.Parser Off\n    K8S-Logging.Exclude Off\n    Kube_Meta_Cache_TTL 3600s\n    Buffer_Size 0\n    #Use_Kubelet true\n\n{{- if index .Values \"config\" \"extraRecords\" }}\n\n[FILTER]\n    Name record_modifier\n    Match cri.*\n    {{- range $k,$v := index .Values \"config\" \"extraRecords\" }}\n    Record {{ $k }} {{ $v }}\n    {{- end }}\n{{- end }}\n\n[FILTER]\n    Name rewrite_tag\n    Match cri.*\n    Emitter_Name kube_tag_rewriter\n    Rule $kubernetes['pod_id'] .* kube.$kubernetes['namespace_name'].$kubernetes['container_name'] false\n\n[FILTER]\n    Name    lua\n    Match   kube.*\n    script  /fluent-bit/scripts/kubezero.lua\n    call    nest_k8s_ns\n"` |  |
| fluent-bit.config.flushInterval | int | `5` |  |
| fluent-bit.config.input.memBufLimit | string | `"16MB"` |  |
| fluent-bit.config.input.refreshInterval | int | `5` |  |
| fluent-bit.config.inputs | string | `"[INPUT]\n    Name tail\n    Path /var/log/containers/*.log\n    # Exclude ourselves to current error spam, https://github.com/fluent/fluent-bit/issues/5769\n    Exclude_Path *logging-fluent-bit*\n    multiline.parser cri\n    Tag cri.*\n    Skip_Long_Lines On\n    Skip_Empty_Lines On\n    DB /var/log/flb_kube.db\n    DB.Sync Normal\n    DB.locking true\n    # Buffer_Max_Size 1M\n    {{- with .Values.config.input }}\n    Mem_Buf_Limit {{ default \"16MB\" .memBufLimit }}\n    Refresh_Interval {{ default 5 .refreshInterval }}\n    {{- end }}\n"` |  |
| fluent-bit.config.logLevel | string | `"info"` |  |
| fluent-bit.config.output.host | string | `"logging-fluentd"` |  |
| fluent-bit.config.output.sharedKey | string | `"cloudbender"` |  |
| fluent-bit.config.output.tls | bool | `false` |  |
| fluent-bit.config.outputs | string | `"[OUTPUT]\n    Match *\n    Name forward\n    Host {{ .Values.config.output.host }}\n    Port 24224\n    Shared_Key {{ .Values.config.output.sharedKey }}\n    tls {{ ternary \"on\" \"off\" .Values.config.output.tls }}\n    Send_options true\n    Require_ack_response true\n"` |  |
| fluent-bit.config.service | string | `"[SERVICE]\n    Flush {{ .Values.config.flushInterval }}\n    Daemon Off\n    Log_Level {{ .Values.config.logLevel }}\n    Parsers_File parsers.conf\n    Parsers_File custom_parsers.conf\n    HTTP_Server On\n    HTTP_Listen 0.0.0.0\n    HTTP_Port {{ .Values.service.port }}\n    Health_Check On\n"` |  |
| fluent-bit.daemonSetVolumeMounts[0].mountPath | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumeMounts[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumeMounts[1].mountPath | string | `"/var/lib/containers/logs"` |  |
| fluent-bit.daemonSetVolumeMounts[1].name | string | `"newlog"` |  |
| fluent-bit.daemonSetVolumes[0].hostPath.path | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumes[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumes[1].hostPath.path | string | `"/var/lib/containers/logs"` |  |
| fluent-bit.daemonSetVolumes[1].name | string | `"newlog"` |  |
| fluent-bit.enabled | bool | `false` |  |
| fluent-bit.luaScripts."kubezero.lua" | string | `"function nest_k8s_ns(tag, timestamp, record)\n    if not record['kubernetes']['namespace_name'] then\n        return 0, 0, 0\n    end\n    new_record = {}\n    for key, val in pairs(record) do\n        if key == 'kube' then\n            new_record[key] = {}\n            new_record[key][record['kubernetes']['namespace_name']] = record[key]\n        else\n            new_record[key] = record[key]\n        end\n    end\n    return 1, timestamp, new_record\nend\n"` |  |
| fluent-bit.resources.limits.memory | string | `"128Mi"` |  |
| fluent-bit.resources.requests.cpu | string | `"20m"` |  |
| fluent-bit.resources.requests.memory | string | `"48Mi"` |  |
| fluent-bit.serviceMonitor.enabled | bool | `false` |  |
| fluent-bit.serviceMonitor.selector.release | string | `"metrics"` |  |
| fluent-bit.testFramework.enabled | bool | `false` |  |
| fluent-bit.tolerations[0].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| fluent-bit.tolerations[1].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[1].key | string | `"kubezero-workergroup"` |  |
| fluent-bit.tolerations[1].operator | string | `"Exists"` |  |
| fluent-bit.tolerations[2].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[2].key | string | `"nvidia.com/gpu"` |  |
| fluent-bit.tolerations[2].operator | string | `"Exists"` |  |
| fluent-bit.tolerations[3].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[3].key | string | `"aws.amazon.com/neuron"` |  |
| fluent-bit.tolerations[3].operator | string | `"Exists"` |  |
| fluent-bit.tolerations[4].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[4].key | string | `"ebs.csi.aws.com/agent-not-ready"` |  |
| fluent-bit.tolerations[4].operator | string | `"Exists"` |  |
| fluent-bit.tolerations[5].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[5].key | string | `"efs.csi.aws.com/agent-not-ready"` |  |
| fluent-bit.tolerations[5].operator | string | `"Exists"` |  |
| fluentd.configMapConfigs[0] | string | `"fluentd-prometheus-conf"` |  |
| fluentd.dashboards.enabled | bool | `false` |  |
| fluentd.enabled | bool | `false` |  |
| fluentd.env[0].name | string | `"OUTPUT_PASSWORD"` |  |
| fluentd.env[0].valueFrom.secretKeyRef.key | string | `"elastic"` |  |
| fluentd.env[0].valueFrom.secretKeyRef.name | string | `"logging-es-elastic-user"` |  |
| fluentd.fileConfigs."00_system.conf" | string | `"<system>\n  root_dir /fluentd/log\n  log_level info\n  ignore_repeated_log_interval 60s\n  ignore_same_log_interval 60s\n  workers 1\n</system>"` |  |
| fluentd.fileConfigs."01_sources.conf" | string | `"<source>\n  @type http\n  @label @KUBERNETES\n  port 9880\n  bind 0.0.0.0\n  keepalive_timeout 30\n</source>\n\n<source>\n  @type forward\n  @label @KUBERNETES\n  port 24224\n  bind 0.0.0.0\n  # skip_invalid_event true\n  send_keepalive_packet true\n  <security>\n    self_hostname \"#{ENV['HOSTNAME']}\"\n    shared_key {{ .Values.shared_key }}\n  </security>\n</source>"` |  |
| fluentd.fileConfigs."02_filters.conf" | string | `"<label @KUBERNETES>\n  # prevent log feedback loops eg. ES has issues etc.\n  # discard logs from our own pods\n  <match kube.logging.fluentd>\n    @type relabel\n    @label @FLUENT_LOG\n  </match>\n\n  # Exclude current fluent-bit multiline noise\n  <filter kube.logging.fluent-bit>\n    @type grep\n    <exclude>\n      key log\n      pattern /could not append content to multiline context/\n    </exclude>\n  </filter>\n\n  # Generate Hash ID to break endless loop for already ingested events during retries\n  <filter **>\n    @type elasticsearch_genid\n    use_entire_record true\n  </filter>\n\n  # Route through DISPATCH for Prometheus metrics\n  <match **>\n    @type relabel\n    @label @DISPATCH\n  </match>\n</label>"` |  |
| fluentd.fileConfigs."04_outputs.conf" | string | `"<label @OUTPUT>\n  <match **>\n    @id out_es\n    @type elasticsearch\n    # @log_level debug\n    include_tag_key true\n\n    id_key _hash\n    remove_keys _hash\n    write_operation create\n\n    # KubeZero pipeline incl. GeoIP etc.\n    pipeline fluentd\n\n    hosts \"{{ .Values.output.host }}\"\n    port 9200\n    scheme http\n    user elastic\n    password \"#{ENV['OUTPUT_PASSWORD']}\"\n\n    log_es_400_reason\n    logstash_format true\n    reconnect_on_error true\n    reload_on_failure true\n    request_timeout 300s\n    slow_flush_log_threshold 55.0\n\n    #with_transporter_log true\n\n    verify_es_version_at_startup false\n    default_elasticsearch_version 7\n    suppress_type_name true\n\n    # Retry failed bulk requests\n    # https://github.com/uken/fluent-plugin-elasticsearch#unrecoverable-error-types\n    unrecoverable_error_types [\"out_of_memory_error\"]\n    bulk_message_request_threshold 1048576\n\n    <buffer>\n      @type file\n\n      flush_mode interval\n      flush_thread_count 2\n      flush_interval 10s\n\n      chunk_limit_size 2MB\n      total_limit_size 1GB\n\n      flush_at_shutdown true\n      retry_type exponential_backoff\n      retry_timeout 6h\n      overflow_action drop_oldest_chunk\n      disable_chunk_backup true\n    </buffer>\n  </match>\n</label>"` |  |
| fluentd.image.repository | string | `"public.ecr.aws/zero-downtime/fluentd-concenter"` |  |
| fluentd.image.tag | string | `"v1.16.3"` |  |
| fluentd.istio.enabled | bool | `false` |  |
| fluentd.kind | string | `"Deployment"` |  |
| fluentd.metrics.serviceMonitor.additionalLabels.release | string | `"metrics"` |  |
| fluentd.metrics.serviceMonitor.enabled | bool | `false` |  |
| fluentd.mountDockerContainersDirectory | bool | `false` |  |
| fluentd.mountVarLogDirectory | bool | `false` |  |
| fluentd.output.host | string | `"logging-es-http"` |  |
| fluentd.podSecurityPolicy.enabled | bool | `false` |  |
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
| kibana.count | int | `1` |  |
| kibana.istio.enabled | bool | `false` |  |
| kibana.istio.gateway | string | `"istio-system/ingressgateway"` |  |
| kibana.istio.url | string | `""` |  |
| networkPolicy.agentSelector."app.kubernetes.io/component" | string | `"Agent"` |  |
| networkPolicy.agentSelector."app.kubernetes.io/name" | string | `"vector-agent"` |  |
| networkPolicy.enabled | bool | `false` |  |
| opensearch-dashboards.enabled | bool | `false` |  |
| opensearch-dashboards.istio.enabled | bool | `false` |  |
| opensearch-dashboards.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| opensearch-dashboards.istio.url | string | `"logging-dashboard.example.com"` |  |
| opensearch-dashboards.resources.limits.cpu | string | `nil` |  |
| opensearch-dashboards.resources.limits.memory | string | `"512M"` |  |
| opensearch-dashboards.resources.requests.cpu | string | `"100m"` |  |
| opensearch-dashboards.resources.requests.memory | string | `"512M"` |  |
| opensearch-dashboards.serviceMonitor.enabled | bool | `false` |  |
| opensearch-dashboards.serviceMonitor.interval | string | `"30s"` |  |
| opensearch.config."opensearch.yml" | string | `"cluster.name: opensearch-cluster\nnetwork.host: 0.0.0.0\ndiscovery.type: single-node\n"` |  |
| opensearch.enabled | bool | `false` |  |
| opensearch.maxUnavailable | int | `0` |  |
| opensearch.opensearchJavaOpts | string | `"-Xmx1024M -Xms1024M"` |  |
| opensearch.persistence.size | string | `"8Gi"` |  |
| opensearch.resources.limits.memory | string | `"2Gi"` |  |
| opensearch.resources.requests.cpu | string | `"500m"` |  |
| opensearch.resources.requests.memory | string | `"2Gi"` |  |
| opensearch.serviceMonitor.enabled | bool | `false` |  |
| opensearch.serviceMonitor.interval | string | `"30s"` |  |
| opensearch.singleNode | bool | `true` |  |
| osdashboards.enabled | bool | `false` |  |
| osdashboards.endpoint | string | `"http://logging-opensearch-dashboards:5601"` |  |
| osdashboards.services[0] | string | `"cloudfront"` |  |
| osdashboards.services[1] | string | `"cloudtrail"` |  |
| osdashboards.services[2] | string | `"s3-access-logs"` |  |
| osdashboards.services[3] | string | `"lambda"` |  |
| vector-agent.containerPorts[0].containerPort | int | `9090` |  |
| vector-agent.containerPorts[0].name | string | `"prom-exporter"` |  |
| vector-agent.containerPorts[0].protocol | string | `"TCP"` |  |
| vector-agent.dataDir | string | `"/vector-data-dir"` |  |
| vector-agent.defaultVolumeMounts[0].mountPath | string | `"/var/log/"` |  |
| vector-agent.defaultVolumeMounts[0].name | string | `"var-log"` |  |
| vector-agent.defaultVolumeMounts[0].readOnly | bool | `true` |  |
| vector-agent.defaultVolumes[0].hostPath.path | string | `"/var/log/"` |  |
| vector-agent.defaultVolumes[0].name | string | `"var-log"` |  |
| vector-agent.enabled | bool | `false` |  |
| vector-agent.existingConfigMaps[0] | string | `"vector-agent-config"` |  |
| vector-agent.image.base | string | `"alpine"` |  |
| vector-agent.podMonitor.enabled | bool | `false` |  |
| vector-agent.podMonitor.honorLabels | bool | `true` |  |
| vector-agent.podMonitor.interval | string | `"30s"` |  |
| vector-agent.resources.limits.memory | string | `"256Mi"` |  |
| vector-agent.resources.requests.cpu | string | `"10m"` |  |
| vector-agent.resources.requests.memory | string | `"64Mi"` |  |
| vector-agent.role | string | `"Agent"` |  |
| vector-agent.service.enabled | bool | `false` |  |
| vector-agent.serviceHeadless.enabled | bool | `false` |  |
| vector.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/component" | string | `"Aggregator"` |  |
| vector.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"vector"` |  |
| vector.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| vector.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| vector.args[0] | string | `"--config-dir"` |  |
| vector.args[1] | string | `"/etc/vector/"` |  |
| vector.args[2] | string | `"--watch-config"` |  |
| vector.args[3] | string | `"--watch-config-method"` |  |
| vector.args[4] | string | `"poll"` |  |
| vector.cloudfront.indexSuffix | string | `"%Y.%m"` |  |
| vector.cloudtrail.indexSuffix | string | `"%Y.%m"` |  |
| vector.containerPorts[0].containerPort | int | `6000` |  |
| vector.containerPorts[0].name | string | `"vector"` |  |
| vector.containerPorts[0].protocol | string | `"TCP"` |  |
| vector.containerPorts[1].containerPort | int | `8080` |  |
| vector.containerPorts[1].name | string | `"http"` |  |
| vector.containerPorts[1].protocol | string | `"TCP"` |  |
| vector.containerPorts[2].containerPort | int | `8686` |  |
| vector.containerPorts[2].name | string | `"api"` |  |
| vector.containerPorts[2].protocol | string | `"TCP"` |  |
| vector.containerPorts[3].containerPort | int | `9090` |  |
| vector.containerPorts[3].name | string | `"prom-exporter"` |  |
| vector.containerPorts[3].protocol | string | `"TCP"` |  |
| vector.dataDir | string | `"/vector-data-dir"` |  |
| vector.enabled | bool | `false` |  |
| vector.env[0].name | string | `"OPENSEARCH_ENDPOINT"` |  |
| vector.env[0].valueFrom.secretKeyRef.key | string | `"endpoint"` |  |
| vector.env[0].valueFrom.secretKeyRef.name | string | `"vector-opensearch"` |  |
| vector.env[0].valueFrom.secretKeyRef.optional | bool | `true` |  |
| vector.env[1].name | string | `"OPENSEARCH_USER"` |  |
| vector.env[1].valueFrom.secretKeyRef.key | string | `"username"` |  |
| vector.env[1].valueFrom.secretKeyRef.name | string | `"vector-opensearch"` |  |
| vector.env[1].valueFrom.secretKeyRef.optional | bool | `true` |  |
| vector.env[2].name | string | `"OPENSEARCH_PASSWORD"` |  |
| vector.env[2].valueFrom.secretKeyRef.key | string | `"password"` |  |
| vector.env[2].valueFrom.secretKeyRef.name | string | `"vector-opensearch"` |  |
| vector.env[2].valueFrom.secretKeyRef.optional | bool | `true` |  |
| vector.env[3].name | string | `"VECTOR_REMOTE_TOKEN"` |  |
| vector.env[3].valueFrom.secretKeyRef.key | string | `"token"` |  |
| vector.env[3].valueFrom.secretKeyRef.name | string | `"vector-remote-forward"` |  |
| vector.env[3].valueFrom.secretKeyRef.optional | bool | `true` |  |
| vector.existingConfigMaps[0] | string | `"vector-aggregator-config"` |  |
| vector.existingConfigMaps[1] | string | `"vector-cloudtrail-lib"` |  |
| vector.existingConfigMaps[2] | string | `"vector-cloudfront-lib"` |  |
| vector.existingConfigMaps[3] | string | `"vector-s3-access-logs-lib"` |  |
| vector.existingConfigMaps[4] | string | `"vector-lambda-lib"` |  |
| vector.existingConfigMaps[5] | string | `"vector-kubernetes-lib"` |  |
| vector.extraVolumeMounts[0].mountPath | string | `"/etc/vector-auth"` |  |
| vector.extraVolumeMounts[0].name | string | `"http-tokens"` |  |
| vector.extraVolumeMounts[0].readOnly | bool | `true` |  |
| vector.extraVolumes[0].name | string | `"http-tokens"` |  |
| vector.extraVolumes[0].secret.secretName | string | `"vector-http-tokens"` |  |
| vector.geoip.database | string | `"/etc/vector-geoip/db.mmdb"` |  |
| vector.geoip.enabled | bool | `false` |  |
| vector.geoip.image | string | `"public.ecr.aws/zero-downtime/kubezero-geoip:dbip-lite-2026-06"` |  |
| vector.geoip.locale | string | `"en"` |  |
| vector.image.base | string | `"alpine"` |  |
| vector.internalRetention.days | int | `7` |  |
| vector.internalRetention.enabled | bool | `true` |  |
| vector.internalRetention.patterns[0] | string | `"top_queries-*"` |  |
| vector.internalRetention.patterns[1] | string | `"security-auditlog-*"` |  |
| vector.istio.enabled | bool | `false` |  |
| vector.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| vector.istio.ingestPathRegex | string | `"^/ingest/[a-z][a-z0-9._-]*$"` |  |
| vector.istio.url | string | `"vector.example.com"` |  |
| vector.kubernetes.indexSuffix | string | `"%Y.%m.%d"` |  |
| vector.kubernetes.indexTemplate.enabled | bool | `true` |  |
| vector.kubernetes.indexTemplate.replicas | int | `1` |  |
| vector.kubernetes.indexTemplate.shards | int | `1` |  |
| vector.kubernetes.indexTemplate.totalFieldsLimit | int | `2000` |  |
| vector.lambda.indexSuffix | string | `"%Y.%m"` |  |
| vector.persistence.enabled | bool | `false` |  |
| vector.persistence.size | string | `"1Gi"` |  |
| vector.podMonitor.enabled | bool | `false` |  |
| vector.podMonitor.honorLabels | bool | `true` |  |
| vector.podMonitor.interval | string | `"30s"` |  |
| vector.podSecurityContext.fsGroup | int | `1000` |  |
| vector.remoteForward.buffer.maxSize | int | `268435488` |  |
| vector.remoteForward.buffer.whenFull | string | `"block"` |  |
| vector.remoteForward.enabled | bool | `false` |  |
| vector.remoteForward.request.retryAttempts | int | `10` |  |
| vector.remoteForward.tokenSecret.key | string | `"token"` |  |
| vector.remoteForward.tokenSecret.name | string | `"vector-remote-forward"` |  |
| vector.remoteForward.uri | string | `"https://vector.remote.example.com/ingest/forwarded"` |  |
| vector.replicas | int | `1` |  |
| vector.resources.limits.memory | string | `"256Mi"` |  |
| vector.resources.requests.cpu | string | `"10m"` |  |
| vector.resources.requests.memory | string | `"64Mi"` |  |
| vector.role | string | `"Aggregator"` |  |
| vector.s3-access-logs.indexSuffix | string | `"%Y.%m"` |  |
| vector.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| vector.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| vector.securityContext.runAsNonRoot | bool | `true` |  |
| vector.securityContext.runAsUser | int | `1000` |  |
| vector.service.enabled | bool | `true` |  |
| vector.service.ports[0].name | string | `"vector"` |  |
| vector.service.ports[0].port | int | `6000` |  |
| vector.service.ports[0].protocol | string | `"TCP"` |  |
| vector.service.ports[0].targetPort | int | `6000` |  |
| vector.service.ports[1].name | string | `"http"` |  |
| vector.service.ports[1].port | int | `8080` |  |
| vector.service.ports[1].protocol | string | `"TCP"` |  |
| vector.service.ports[1].targetPort | int | `8080` |  |
| vector.service.ports[2].name | string | `"prom-exporter"` |  |
| vector.service.ports[2].port | int | `9090` |  |
| vector.service.ports[2].protocol | string | `"TCP"` |  |
| vector.service.ports[2].targetPort | int | `9090` |  |
| vector.service.type | string | `"ClusterIP"` |  |
| vector.serviceHeadless.enabled | bool | `true` |  |
| vector.serviceHeadless.ports[0].name | string | `"vector"` |  |
| vector.serviceHeadless.ports[0].port | int | `6000` |  |
| vector.serviceHeadless.ports[0].protocol | string | `"TCP"` |  |
| vector.serviceHeadless.ports[0].targetPort | int | `6000` |  |
| vectorHttpIngest.enabled | bool | `false` |  |
| version | string | `"7.17.7"` |  |

## Resources:

- https://www.elastic.co/downloads/elastic-cloud-kubernetes
- https://github.com/elastic/cloud-on-k8s
- https://grafana.com/grafana/dashboards/7752
