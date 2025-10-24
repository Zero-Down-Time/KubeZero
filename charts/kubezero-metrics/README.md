# kubezero-metrics

![Version: 0.12.1](https://img.shields.io/badge/Version-0.12.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for Prometheus, Grafana and Alertmanager as well as all Kubernetes integrations.

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
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 78.4.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-adapter | 5.2.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-pushgateway | 3.4.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| istio.alertmanager.destination | string | `"metrics-kube-prometheus-st-alertmanager"` |  |
| istio.alertmanager.enabled | bool | `false` |  |
| istio.alertmanager.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.alertmanager.ipBlocks | list | `[]` |  |
| istio.alertmanager.port | int | `9093` |  |
| istio.alertmanager.url | string | `""` |  |
| istio.grafana.destination | string | `"metrics-grafana"` |  |
| istio.grafana.enabled | bool | `false` |  |
| istio.grafana.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.grafana.ipBlocks | list | `[]` |  |
| istio.grafana.port | int | `80` |  |
| istio.grafana.url | string | `""` |  |
| istio.prometheus.destination | string | `"metrics-kube-prometheus-st-prometheus"` |  |
| istio.prometheus.enabled | bool | `false` |  |
| istio.prometheus.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.prometheus.ipBlocks | list | `[]` |  |
| istio.prometheus.port | int | `9090` |  |
| istio.prometheus.url | string | `""` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[0].name | string | `"SNS_FORWARDER_ARN_PREFIX"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[0].valueFrom.fieldRef.fieldPath | string | `"metadata.annotations['kubezero.com/sns_forwarder_ARN_PREFIX']"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[1].name | string | `"AWS_ROLE_ARN"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[1].valueFrom.fieldRef.fieldPath | string | `"metadata.annotations['kubezero.com/sns_forwarder_AWS_ROLE_ARN']"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[2].name | string | `"AWS_WEB_IDENTITY_TOKEN_FILE"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[2].value | string | `"/var/run/secrets/sts.amazonaws.com/serviceaccount/token"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[3].name | string | `"AWS_STS_REGIONAL_ENDPOINTS"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].env[3].value | string | `"regional"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].image | string | `"datareply/alertmanager-sns-forwarder:latest"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].imagePullPolicy | string | `"Always"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].livenessProbe.httpGet.path | string | `"/health"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].livenessProbe.httpGet.port | string | `"webhook-port"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].livenessProbe.initialDelaySeconds | int | `30` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].livenessProbe.timeoutSeconds | int | `10` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].name | string | `"alertmanager-sns-forwarder"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].ports[0].containerPort | int | `9087` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].ports[0].name | string | `"webhook-port"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].readinessProbe.httpGet.path | string | `"/health"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].readinessProbe.httpGet.port | string | `"webhook-port"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].readinessProbe.initialDelaySeconds | int | `10` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].readinessProbe.timeoutSeconds | int | `10` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].resources.limits.cpu | string | `"100m"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].resources.limits.memory | string | `"64Mi"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].resources.requests.cpu | string | `"25m"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].resources.requests.memory | string | `"32Mi"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].volumeMounts[0].mountPath | string | `"/var/run/secrets/sts.amazonaws.com/serviceaccount/"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].volumeMounts[0].name | string | `"aws-token"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers[0].volumeMounts[0].readOnly | bool | `true` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.logFormat | string | `"json"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.volumes[0].name | string | `"aws-token"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.volumes[0].projected.sources[0].serviceAccountToken.audience | string | `"sts.amazonaws.com"` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.volumes[0].projected.sources[0].serviceAccountToken.expirationSeconds | int | `86400` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.volumes[0].projected.sources[0].serviceAccountToken.path | string | `"token"` |  |
| kube-prometheus-stack.alertmanager.config.global.resolve_timeout | string | `"5m"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[0].equal[0] | string | `"namespace"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[0].equal[1] | string | `"alertname"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[0].source_matchers[0] | string | `"severity = critical"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[0].target_matchers[0] | string | `"severity =~ warning|info"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[1].equal[0] | string | `"namespace"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[1].equal[1] | string | `"alertname"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[1].source_matchers[0] | string | `"severity = warning"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[1].target_matchers[0] | string | `"severity = info"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[2].equal[0] | string | `"namespace"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[2].source_matchers[0] | string | `"alertname = InfoInhibitor"` |  |
| kube-prometheus-stack.alertmanager.config.inhibit_rules[2].target_matchers[0] | string | `"severity = info"` |  |
| kube-prometheus-stack.alertmanager.config.route.group_by[0] | string | `"alertname"` |  |
| kube-prometheus-stack.alertmanager.config.route.group_by[1] | string | `"severity"` |  |
| kube-prometheus-stack.alertmanager.config.route.group_by[2] | string | `"status"` |  |
| kube-prometheus-stack.alertmanager.config.route.group_interval | string | `"5m"` |  |
| kube-prometheus-stack.alertmanager.config.route.group_wait | string | `"30s"` |  |
| kube-prometheus-stack.alertmanager.config.route.repeat_interval | string | `"4h"` |  |
| kube-prometheus-stack.alertmanager.config.route.routes[0].matchers[0] | string | `"severity = none"` |  |
| kube-prometheus-stack.alertmanager.config.route.routes[0].receiver | string | `"null"` |  |
| kube-prometheus-stack.alertmanager.enabled | bool | `false` |  |
| kube-prometheus-stack.coreDns.enabled | bool | `true` |  |
| kube-prometheus-stack.defaultRules.create | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini"."auth.anonymous".enabled | bool | `true` |  |
| kube-prometheus-stack.grafana."grafana.ini"."log.console".format | string | `"json"` |  |
| kube-prometheus-stack.grafana."grafana.ini".alerting.enabled | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini".analytics.check_for_plugin_updates | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini".analytics.check_for_updates | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini".dashboards.default_home_dashboard_path | string | `"/tmp/dashboards/KubeZero/home.json"` |  |
| kube-prometheus-stack.grafana."grafana.ini".dashboards.min_refresh_interval | string | `"30s"` |  |
| kube-prometheus-stack.grafana."grafana.ini".date_formats.default_timezone | string | `"UTC"` |  |
| kube-prometheus-stack.grafana."grafana.ini".security.cookie_secure | bool | `true` |  |
| kube-prometheus-stack.grafana."grafana.ini".security.disable_gravatar | bool | `true` |  |
| kube-prometheus-stack.grafana."grafana.ini".security.strict_transport_security | bool | `true` |  |
| kube-prometheus-stack.grafana."grafana.ini".server.enable_gzip | bool | `true` |  |
| kube-prometheus-stack.grafana.defaultDashboardsEnabled | bool | `false` |  |
| kube-prometheus-stack.grafana.enabled | bool | `true` |  |
| kube-prometheus-stack.grafana.extraContainerVolumes[0].configMap.defaultMode | int | `511` |  |
| kube-prometheus-stack.grafana.extraContainerVolumes[0].configMap.name | string | `"script-configmap"` |  |
| kube-prometheus-stack.grafana.extraContainerVolumes[0].name | string | `"script-volume"` |  |
| kube-prometheus-stack.grafana.initChownData.enabled | bool | `false` |  |
| kube-prometheus-stack.grafana.plugins[0] | string | `"grafana-piechart-panel"` |  |
| kube-prometheus-stack.grafana.service.portName | string | `"http-grafana"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.extraMounts[0].mountPath | string | `"/opt/script.sh"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.extraMounts[0].name | string | `"script-volume"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.extraMounts[0].subPath | string | `"script.sh"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.provider.foldersFromFilesStructure | bool | `true` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.script | string | `"/opt/script.sh"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.searchNamespace | string | `"ALL"` |  |
| kube-prometheus-stack.grafana.testFramework.enabled | bool | `false` |  |
| kube-prometheus-stack.kube-state-metrics.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| kube-prometheus-stack.kube-state-metrics.tolerations[0].effect | string | `"NoSchedule"` |  |
| kube-prometheus-stack.kube-state-metrics.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| kube-prometheus-stack.kubeApiServer.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeControllerManager.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeControllerManager.service.port | int | `10257` |  |
| kube-prometheus-stack.kubeControllerManager.service.targetPort | int | `10257` |  |
| kube-prometheus-stack.kubeControllerManager.serviceMonitor.https | bool | `true` |  |
| kube-prometheus-stack.kubeControllerManager.serviceMonitor.insecureSkipVerify | bool | `true` |  |
| kube-prometheus-stack.kubeDns.enabled | bool | `false` |  |
| kube-prometheus-stack.kubeEtcd.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeEtcd.service.port | int | `2381` |  |
| kube-prometheus-stack.kubeEtcd.service.targetPort | int | `2381` |  |
| kube-prometheus-stack.kubeProxy.enabled | bool | `false` |  |
| kube-prometheus-stack.kubeScheduler.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.service.port | int | `10259` |  |
| kube-prometheus-stack.kubeScheduler.service.targetPort | int | `10259` |  |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.https | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.insecureSkipVerify | bool | `true` |  |
| kube-prometheus-stack.kubeStateMetrics.enabled | bool | `true` |  |
| kube-prometheus-stack.kubelet.enabled | bool | `true` |  |
| kube-prometheus-stack.kubelet.serviceMonitor.cAdvisor | bool | `true` |  |
| kube-prometheus-stack.nodeExporter.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus-node-exporter.hostRootFsMount.enabled | bool | `false` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].action | string | `"replace"` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].regex | string | `"^(.*)$"` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].replacement | string | `"$1"` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].separator | string | `";"` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].sourceLabels[0] | string | `"__meta_kubernetes_pod_node_name"` |  |
| kube-prometheus-stack.prometheus-node-exporter.prometheus.monitor.relabelings[0].targetLabel | string | `"instance"` |  |
| kube-prometheus-stack.prometheus-node-exporter.resources.requests.cpu | string | `"20m"` |  |
| kube-prometheus-stack.prometheus-node-exporter.resources.requests.memory | string | `"24Mi"` |  |
| kube-prometheus-stack.prometheus.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.logFormat | string | `"json"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.portName | string | `"http-prometheus"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.probeSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.memory | string | `"4Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.cpu | string | `"500m"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory | string | `"2Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.retention | string | `"8d"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.scrapeConfigSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage | string | `"16Gi"` |  |
| kube-prometheus-stack.prometheusOperator.admissionWebhooks.certManager.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheusOperator.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheusOperator.logFormat | string | `"json"` |  |
| kube-prometheus-stack.prometheusOperator.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| kube-prometheus-stack.prometheusOperator.resources.limits.memory | string | `"128Mi"` |  |
| kube-prometheus-stack.prometheusOperator.resources.requests.cpu | string | `"10m"` |  |
| kube-prometheus-stack.prometheusOperator.resources.requests.memory | string | `"64Mi"` |  |
| kube-prometheus-stack.prometheusOperator.tolerations[0].effect | string | `"NoSchedule"` |  |
| kube-prometheus-stack.prometheusOperator.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| prometheus-adapter.enabled | bool | `true` |  |
| prometheus-adapter.logLevel | int | `1` |  |
| prometheus-adapter.metricsRelistInterval | string | `"3m"` |  |
| prometheus-adapter.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| prometheus-adapter.prometheus.url | string | `"http://metrics-kube-prometheus-st-prometheus"` |  |
| prometheus-adapter.rules.default | bool | `false` |  |
| prometheus-adapter.rules.resource.cpu.containerLabel | string | `"container"` |  |
| prometheus-adapter.rules.resource.cpu.containerQuery | string | `"sum by (<<.GroupBy>>) (\n  irate (\n      container_cpu_usage_seconds_total{<<.LabelMatchers>>,container!=\"\",pod!=\"\"}[120s]\n  )\n)\n"` |  |
| prometheus-adapter.rules.resource.cpu.nodeQuery | string | `"sum(1 - irate(node_cpu_seconds_total{<<.LabelMatchers>>, mode=\"idle\"}[120s])) by (<<.GroupBy>>)\n"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.instance.resource | string | `"node"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.namespace.resource | string | `"namespace"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.pod.resource | string | `"pod"` |  |
| prometheus-adapter.rules.resource.memory.containerLabel | string | `"container"` |  |
| prometheus-adapter.rules.resource.memory.containerQuery | string | `"sum by (<<.GroupBy>>) (\n  container_memory_working_set_bytes{<<.LabelMatchers>>,container!=\"\",pod!=\"\",container!=\"POD\"}\n)\n"` |  |
| prometheus-adapter.rules.resource.memory.nodeQuery | string | `"sum(node_memory_MemTotal_bytes{<<.LabelMatchers>>} - node_memory_MemAvailable_bytes{<<.LabelMatchers>>}) by (<<.GroupBy>>)\n"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.instance.resource | string | `"node"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.namespace.resource | string | `"namespace"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.pod.resource | string | `"pod"` |  |
| prometheus-adapter.rules.resource.window | string | `"2m"` |  |
| prometheus-adapter.tolerations[0].effect | string | `"NoSchedule"` |  |
| prometheus-adapter.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| prometheus-pushgateway.enabled | bool | `false` |  |
| prometheus-pushgateway.serviceMonitor.enabled | bool | `true` |  |

# Dashboards

## Alertmanager
- https://grafana.com/api/dashboards/9578/revisions/4/download
## Prometheus
- https://grafana.com/api/dashboards/3662/revisions/2/download
## AlertManager SNS Forwarder
- https://github.com/DataReply/alertmanager-sns-forwarder
## docker-registry
- https://github.com/lstn/misc-grafana-dashboards/blob/master/dashboards/docker-registry.json
