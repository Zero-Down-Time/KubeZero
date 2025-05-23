# kubezero-telemetry

![Version: 0.4.2](https://img.shields.io/badge/Version-0.4.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for OpenTelemetry, Jaeger etc.

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://fluent.github.io/helm-charts | fluent-bit | 0.49.0 |
| https://fluent.github.io/helm-charts | fluentd | 0.5.3 |
| https://jaegertracing.github.io/helm-charts | jaeger | 3.4.1 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.125.0 |
| https://opensearch-project.github.io/helm-charts/ | data-prepper | 0.3.1 |
| https://opensearch-project.github.io/helm-charts/ | opensearch | 3.0.0 |
| https://opensearch-project.github.io/helm-charts/ | opensearch-dashboards | 3.0.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| data-prepper.config."data-prepper-config.yaml" | string | `"ssl: false\npeer_forwarder:\n  ssl: false\n"` |  |
| data-prepper.config."log4j2-rolling.properties" | string | `"status = error\ndest = err\nname = PropertiesConfig\n\nappender.console.type = Console\nappender.console.name = STDOUT\nappender.console.layout.type = PatternLayout\nappender.console.layout.pattern = %d{ISO8601} [%t] %-5p %40C - %m%n\n\nrootLogger.level = warn\nrootLogger.appenderRef.stdout.ref = STDOUT\n\nlogger.pipeline.name = org.opensearch.dataprepper.pipeline\nlogger.pipeline.level = info\n\nlogger.parser.name = org.opensearch.dataprepper.parser\nlogger.parser.level = info\n\nlogger.plugins.name = org.opensearch.dataprepper.plugins\nlogger.plugins.level = info\n"` |  |
| data-prepper.enabled | bool | `false` |  |
| data-prepper.image.tag | string | `"2.10.1"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.buffer.bounded_blocking | string | `nil` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.delay | int | `3000` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.processor[0].service_map.window_duration | int | `180` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.bulk_size | int | `4` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.hosts[0] | string | `"https://telemetry:9200"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.index_type | string | `"trace-analytics-service-map"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.insecure | bool | `true` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.password | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.sink[0].opensearch.username | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.source.pipeline.name | string | `"otel-trace-pipeline"` |  |
| data-prepper.pipelineConfig.config.otel-service-map-pipeline.workers | int | `1` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.buffer.bounded_blocking | string | `nil` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.delay | string | `"100"` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.sink[0].pipeline.name | string | `"raw-traces-pipeline"` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.sink[1].pipeline.name | string | `"otel-service-map-pipeline"` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.source.otel_trace_source.ssl | bool | `false` |  |
| data-prepper.pipelineConfig.config.otel-trace-pipeline.workers | int | `1` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.buffer.bounded_blocking | string | `nil` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.delay | int | `3000` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.processor[0].otel_traces | string | `nil` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.processor[1].otel_trace_group.hosts[0] | string | `"https://telemetry:9200"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.processor[1].otel_trace_group.insecure | bool | `true` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.processor[1].otel_trace_group.password | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.processor[1].otel_trace_group.username | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.sink[0].opensearch.hosts[0] | string | `"https://telemetry:9200"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.sink[0].opensearch.index_type | string | `"trace-analytics-raw"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.sink[0].opensearch.insecure | bool | `true` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.sink[0].opensearch.password | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.sink[0].opensearch.username | string | `"admin"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.source.pipeline.name | string | `"otel-trace-pipeline"` |  |
| data-prepper.pipelineConfig.config.raw-traces-pipeline.workers | int | `1` |  |
| data-prepper.pipelineConfig.config.simple-sample-pipeline | string | `nil` |  |
| data-prepper.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| fluent-bit.config.customParsers | string | `"[PARSER]\n    Name cri-log\n    Format regex\n    Regex ^(?<time>.+) (?<stream>stdout|stderr) (?<logtag>F|P) (?<log>.*)$\n    Time_Key    time\n    Time_Format %Y-%m-%dT%H:%M:%S.%L%z\n"` |  |
| fluent-bit.config.filters | string | `"[FILTER]\n    Name parser\n    Match cri.*\n    Parser cri-log\n    Key_Name log\n\n[FILTER]\n    Name kubernetes\n    Match cri.*\n    Merge_Log On\n    Merge_Log_Key kube\n    Kube_Tag_Prefix cri.var.log.containers.\n    Keep_Log Off\n    Annotations Off\n    K8S-Logging.Parser Off\n    K8S-Logging.Exclude Off\n    Kube_Meta_Cache_TTL 3600s\n    Buffer_Size 0\n    #Use_Kubelet true\n\n{{- if index .Values \"config\" \"extraRecords\" }}\n\n[FILTER]\n    Name record_modifier\n    Match cri.*\n    {{- range $k,$v := index .Values \"config\" \"extraRecords\" }}\n    Record {{ $k }} {{ $v }}\n    {{- end }}\n{{- end }}\n\n[FILTER]\n    Name rewrite_tag\n    Match cri.*\n    Emitter_Name kube_tag_rewriter\n    Rule $kubernetes['pod_id'] .* kube.$kubernetes['namespace_name'].$kubernetes['container_name'] false\n\n[FILTER]\n    Name    lua\n    Match   kube.*\n    script  /fluent-bit/scripts/kubezero.lua\n    call    nest_k8s_ns\n"` |  |
| fluent-bit.config.flushInterval | int | `5` |  |
| fluent-bit.config.input.memBufLimit | string | `"16MB"` |  |
| fluent-bit.config.input.refreshInterval | int | `5` |  |
| fluent-bit.config.inputs | string | `"[INPUT]\n    Name tail\n    Path /var/log/containers/*.log\n    # Exclude ourselves to current error spam, https://github.com/fluent/fluent-bit/issues/5769\n    # Todo: Rather limit / filter spam message than exclude all together -> ideally locally, next dataprepper\n    Exclude_Path *logging-fluent-bit*\n    multiline.parser cri\n    Tag cri.*\n    Skip_Long_Lines On\n    Skip_Empty_Lines On\n    DB /var/log/flb_kube.db\n    DB.Sync Normal\n    DB.locking true\n    # Buffer_Max_Size 1M\n    {{- with .Values.config.input }}\n    Mem_Buf_Limit {{ .memBufLimit }}\n    Refresh_Interval {{ .refreshInterval }}\n    {{- end }}\n\n[INPUT]\n    Name opentelemetry\n    Tag otel\n"` |  |
| fluent-bit.config.logLevel | string | `"info"` |  |
| fluent-bit.config.output.host | string | `"telemetry-fluentd"` |  |
| fluent-bit.config.output.sharedKey | string | `"secretref+k8s://v1/Secret/kubezero/kubezero-secrets/telemetry.fluentd.source.sharedKey"` |  |
| fluent-bit.config.output.tls | bool | `false` |  |
| fluent-bit.config.output_otel.host | string | `"telemetry-opentelemetry-collector"` |  |
| fluent-bit.config.outputs | string | `"[OUTPUT]\n    Match kube.*\n    Name forward\n    Host {{ .Values.config.output.host }}\n    Port 24224\n    Shared_Key {{ .Values.config.output.sharedKey }}\n    tls {{ ternary \"on\" \"off\" .Values.config.output.tls }}\n    Send_options true\n    Require_ack_response true\n\n[OUTPUT]\n    Name opentelemetry\n    Match otel\n    Host {{ .Values.config.output_otel.host }}\n    Port 4318\n    #Metrics_uri /v1/metrics\n    Traces_uri   /v1/traces\n    #Logs_uri    /v1/logs\n"` |  |
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
| fluent-bit.extraPorts[0].containerPort | int | `4318` |  |
| fluent-bit.extraPorts[0].name | string | `"otel"` |  |
| fluent-bit.extraPorts[0].port | int | `4318` |  |
| fluent-bit.extraPorts[0].protocol | string | `"TCP"` |  |
| fluent-bit.luaScripts."kubezero.lua" | string | `"function nest_k8s_ns(tag, timestamp, record)\n    if not record['kubernetes']['namespace_name'] then\n        return 0, 0, 0\n    end\n    new_record = {}\n    for key, val in pairs(record) do\n        if key == 'kube' then\n            new_record[key] = {}\n            new_record[key][record['kubernetes']['namespace_name']] = record[key]\n        else\n            new_record[key] = record[key]\n        end\n    end\n    return 1, timestamp, new_record\nend\n"` |  |
| fluent-bit.resources.limits.memory | string | `"128Mi"` |  |
| fluent-bit.resources.requests.cpu | string | `"20m"` |  |
| fluent-bit.resources.requests.memory | string | `"48Mi"` |  |
| fluent-bit.service.internalTrafficPolicy | string | `"Local"` |  |
| fluent-bit.serviceMonitor.enabled | bool | `false` |  |
| fluent-bit.testFramework.enabled | bool | `false` |  |
| fluent-bit.tolerations[0].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[0].operator | string | `"Exists"` |  |
| fluentd.configMapConfigs[0] | string | `"fluentd-prometheus-conf"` |  |
| fluentd.dashboards.enabled | bool | `false` |  |
| fluentd.enabled | bool | `false` |  |
| fluentd.fileConfigs."00_system.conf" | string | `"<system>\n  root_dir /fluentd/log\n  log_level info\n  ignore_repeated_log_interval 60s\n  ignore_same_log_interval 60s\n  workers 1\n</system>"` |  |
| fluentd.fileConfigs."01_sources.conf" | string | `"<source>\n  @type http\n  @label @KUBERNETES\n  port 9880\n  bind 0.0.0.0\n  keepalive_timeout 30\n</source>\n\n<source>\n  @type forward\n  @label @KUBERNETES\n  port 24224\n  bind 0.0.0.0\n  # skip_invalid_event true\n  send_keepalive_packet true\n  <security>\n    self_hostname \"telemetry-fluentd\"\n    shared_key {{ .Values.source.sharedKey }}\n  </security>\n</source>"` |  |
| fluentd.fileConfigs."02_filters.conf" | string | `"<label @KUBERNETES>\n  # prevent log feedback loops, discard logs from our own pods\n  <match kube.logging.fluentd>\n    @type relabel\n    @label @FLUENT_LOG\n  </match>\n\n  # Exclude current fluent-bit multiline noise\n  # Still relevant ??\n  <filter kube.logging.fluent-bit>\n    @type grep\n    <exclude>\n      key log\n      pattern /could not append content to multiline context/\n    </exclude>\n  </filter>\n\n  # Generate Hash ID to break endless loop for already ingested events during retries\n  <filter **>\n    @type opensearch_genid\n    use_entire_record true\n  </filter>\n\n  # Route through DISPATCH for Prometheus metrics\n  <match **>\n    @type relabel\n    @label @DISPATCH\n  </match>\n</label>"` |  |
| fluentd.fileConfigs."04_outputs.conf" | string | `"<label @OUTPUT>\n  <match **>\n    @id out_os\n    @type opensearch\n    # @log_level debug\n    include_tag_key true\n\n    id_key _hash\n    remove_keys _hash\n    write_operation create\n\n    # we have oj in the fluentd-concenter image\n    prefer_oj_serializer true\n\n    # KubeZero pipeline incl. GeoIP etc.\n    #pipeline fluentd\n\n    http_backend typhoeus\n    ca_file /run/pki/ca.crt\n\n    port 9200\n    scheme https\n    hosts {{ .Values.output.host }}\n    user {{ .Values.output.user }}\n    password {{ .Values.output.password }}\n\n    log_es_400_reason\n    logstash_format true\n    reconnect_on_error true\n    reload_on_failure true\n    request_timeout 300s\n    #sniffer_class_name Fluent::Plugin::OpenSearchSimpleSniffer\n\n    #with_transporter_log true\n\n    verify_es_version_at_startup false\n    default_opensearch_version 2\n    #suppress_type_name true\n\n    # Retry failed bulk requests\n    # https://github.com/uken/fluent-plugin-elasticsearch#unrecoverable-error-types\n    unrecoverable_error_types [\"out_of_memory_error\"]\n    bulk_message_request_threshold 1048576\n\n    <buffer>\n      @type file\n\n      flush_mode interval\n      flush_thread_count 2\n      flush_interval 10s\n\n      chunk_limit_size 2MB\n      total_limit_size 1GB\n\n      flush_at_shutdown true\n      retry_type exponential_backoff\n      retry_timeout 6h\n      overflow_action drop_oldest_chunk\n      disable_chunk_backup true\n    </buffer>\n  </match>\n</label>"` |  |
| fluentd.image.repository | string | `"public.ecr.aws/zero-downtime/fluentd-concenter"` |  |
| fluentd.image.tag | string | `"v1.16.5-1-g09dc31c"` |  |
| fluentd.istio.enabled | bool | `false` |  |
| fluentd.kind | string | `"StatefulSet"` |  |
| fluentd.metrics.serviceMonitor.enabled | bool | `false` |  |
| fluentd.mountDockerContainersDirectory | bool | `false` |  |
| fluentd.mountVarLogDirectory | bool | `false` |  |
| fluentd.output.host | string | `"telemetry"` |  |
| fluentd.output.password | string | `"admin"` |  |
| fluentd.output.user | string | `"admin"` |  |
| fluentd.persistence.enabled | bool | `true` |  |
| fluentd.persistence.size | string | `"1Gi"` |  |
| fluentd.persistence.storageClass | string | `""` |  |
| fluentd.rbac.create | bool | `false` |  |
| fluentd.replicaCount | int | `1` |  |
| fluentd.resources.limits.memory | string | `"512Mi"` |  |
| fluentd.resources.requests.cpu | string | `"200m"` |  |
| fluentd.resources.requests.memory | string | `"256Mi"` |  |
| fluentd.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| fluentd.securityContext.runAsNonRoot | bool | `true` |  |
| fluentd.securityContext.runAsUser | int | `100` |  |
| fluentd.service.ports[0].containerPort | int | `24224` |  |
| fluentd.service.ports[0].name | string | `"tcp-forward"` |  |
| fluentd.service.ports[0].protocol | string | `"TCP"` |  |
| fluentd.service.ports[1].containerPort | int | `9880` |  |
| fluentd.service.ports[1].name | string | `"http-fluentd"` |  |
| fluentd.service.ports[1].protocol | string | `"TCP"` |  |
| fluentd.source.sharedKey | string | `"secretref+k8s://v1/Secret/kubezero/kubezero-secrets/telemetry.fluentd.source.sharedKey?inCluster"` |  |
| fluentd.volumeMounts[0].mountPath | string | `"/run/pki"` |  |
| fluentd.volumeMounts[0].name | string | `"trust-store"` |  |
| fluentd.volumeMounts[0].readOnly | bool | `true` |  |
| fluentd.volumes[0].name | string | `"trust-store"` |  |
| fluentd.volumes[0].secret.items[0].key | string | `"tls.crt"` |  |
| fluentd.volumes[0].secret.items[0].path | string | `"ca.crt"` |  |
| fluentd.volumes[0].secret.secretName | string | `"telemetry-nodes-http-tls"` |  |
| jaeger.agent.enabled | bool | `false` |  |
| jaeger.collector.service.otlp.grpc.name | string | `"otlp-grpc"` |  |
| jaeger.collector.service.otlp.grpc.port | int | `4317` |  |
| jaeger.collector.service.otlp.http.name | string | `"otlp-http"` |  |
| jaeger.collector.service.otlp.http.port | int | `4318` |  |
| jaeger.collector.serviceMonitor.enabled | bool | `false` |  |
| jaeger.enabled | bool | `false` |  |
| jaeger.istio.enabled | bool | `false` |  |
| jaeger.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| jaeger.istio.url | string | `"jaeger.example.com"` |  |
| jaeger.provisionDataStore.cassandra | bool | `false` |  |
| jaeger.provisionDataStore.elasticsearch | bool | `false` |  |
| jaeger.query.agentSidecar.enabled | bool | `false` |  |
| jaeger.query.serviceMonitor.enabled | bool | `false` |  |
| jaeger.storage.elasticsearch.cmdlineParams."es.num-replicas" | int | `1` |  |
| jaeger.storage.elasticsearch.cmdlineParams."es.num-shards" | int | `2` |  |
| jaeger.storage.elasticsearch.cmdlineParams."es.tls.enabled" | string | `""` |  |
| jaeger.storage.elasticsearch.cmdlineParams."es.tls.skip-host-verify" | string | `""` |  |
| jaeger.storage.elasticsearch.host | string | `"telemetry"` |  |
| jaeger.storage.elasticsearch.password | string | `"admin"` |  |
| jaeger.storage.elasticsearch.scheme | string | `"https"` |  |
| jaeger.storage.elasticsearch.user | string | `"admin"` |  |
| jaeger.storage.type | string | `"elasticsearch"` |  |
| metrics.enabled | bool | `false` |  |
| opensearch-dashboards.enabled | bool | `false` |  |
| opensearch-dashboards.istio.enabled | bool | `false` |  |
| opensearch-dashboards.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| opensearch-dashboards.istio.url | string | `"telemetry-dashboard.example.com"` |  |
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
| opentelemetry-collector.config.exporters.otlp/data-prepper.endpoint | string | `"telemetry-data-prepper:21890"` |  |
| opentelemetry-collector.config.exporters.otlp/data-prepper.tls.insecure | bool | `true` |  |
| opentelemetry-collector.config.exporters.otlp/jaeger.endpoint | string | `"telemetry-jaeger-collector:4317"` |  |
| opentelemetry-collector.config.exporters.otlp/jaeger.tls.insecure | bool | `true` |  |
| opentelemetry-collector.config.extensions.health_check.endpoint | string | `"${env:MY_POD_IP}:13133"` |  |
| opentelemetry-collector.config.receivers.otlp.protocols.grpc.endpoint | string | `"${env:MY_POD_IP}:4317"` |  |
| opentelemetry-collector.config.receivers.otlp.protocols.http.endpoint | string | `"${env:MY_POD_IP}:4318"` |  |
| opentelemetry-collector.config.service.extensions[0] | string | `"health_check"` |  |
| opentelemetry-collector.config.service.pipelines.traces.exporters[0] | string | `"otlp/jaeger"` |  |
| opentelemetry-collector.config.service.pipelines.traces.exporters[1] | string | `"otlp/data-prepper"` |  |
| opentelemetry-collector.config.service.pipelines.traces.processors[0] | string | `"memory_limiter"` |  |
| opentelemetry-collector.config.service.pipelines.traces.processors[1] | string | `"batch"` |  |
| opentelemetry-collector.config.service.pipelines.traces.receivers[0] | string | `"otlp"` |  |
| opentelemetry-collector.config.service.telemetry.metrics.address | string | `"${env:MY_POD_IP}:8888"` |  |
| opentelemetry-collector.enabled | bool | `false` |  |
| opentelemetry-collector.image.repository | string | `"otel/opentelemetry-collector-contrib"` |  |
| opentelemetry-collector.mode | string | `"deployment"` |  |
| opentelemetry-collector.podDisruptionBudget.enabled | bool | `false` |  |
| opentelemetry-collector.ports.jaeger-compact.enabled | bool | `false` |  |
| opentelemetry-collector.ports.jaeger-grpc.enabled | bool | `false` |  |
| opentelemetry-collector.ports.jaeger-thrift.enabled | bool | `false` |  |
| opentelemetry-collector.ports.metrics.enabled | bool | `true` |  |
| opentelemetry-collector.ports.zipkin.enabled | bool | `false` |  |
| opentelemetry-collector.serviceMonitor.enabled | bool | `false` |  |

## Resources
- https://opensearch.org/docs/latest/dashboards/branding/#condensed-header

