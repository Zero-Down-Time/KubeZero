# kubezero-metrics

![Version: 0.4.1](https://img.shields.io/badge/Version-0.4.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for prometheus-operator

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
|  | kube-prometheus-stack | 16.12.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-adapter | 2.14.2 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| istio.alertmanager.destination | string | `"metrics-kube-prometheus-st-alertmanager"` |  |
| istio.alertmanager.enabled | bool | `false` |  |
| istio.alertmanager.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.alertmanager.ipBlocks | list | `[]` |  |
| istio.alertmanager.url | string | `""` |  |
| istio.grafana.destination | string | `"metrics-grafana"` |  |
| istio.grafana.enabled | bool | `false` |  |
| istio.grafana.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.grafana.ipBlocks | list | `[]` |  |
| istio.grafana.url | string | `""` |  |
| istio.prometheus.destination | string | `"metrics-kube-prometheus-st-prometheus"` |  |
| istio.prometheus.enabled | bool | `false` |  |
| istio.prometheus.gateway | string | `"istio-ingress/ingressgateway"` |  |
| istio.prometheus.ipBlocks | list | `[]` |  |
| istio.prometheus.url | string | `""` |  |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.logFormat | string | `"json"` |  |
| kube-prometheus-stack.alertmanager.enabled | bool | `false` |  |
| kube-prometheus-stack.coreDns.enabled | bool | `true` |  |
| kube-prometheus-stack.defaultRules.create | bool | `true` |  |
| kube-prometheus-stack.global.rbac.pspEnabled | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini"."auth.anonymous".enabled | bool | `true` |  |
| kube-prometheus-stack.grafana."grafana.ini".alerting.enabled | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini".analytics.check_for_updates | bool | `false` |  |
| kube-prometheus-stack.grafana."grafana.ini".dashboards.default_home_dashboard_path | string | `"/tmp/dashboards/home.json"` |  |
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
| kube-prometheus-stack.grafana.rbac.pspEnabled | bool | `false` |  |
| kube-prometheus-stack.grafana.service.portName | string | `"http-grafana"` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.provider.foldersFromFilesStructure | bool | `true` |  |
| kube-prometheus-stack.grafana.sidecar.dashboards.searchNamespace | string | `"ALL"` |  |
| kube-prometheus-stack.grafana.testFramework.enabled | bool | `false` |  |
| kube-prometheus-stack.kube-state-metrics.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| kube-prometheus-stack.kube-state-metrics.podSecurityPolicy.enabled | bool | `false` |  |
| kube-prometheus-stack.kube-state-metrics.tolerations[0].effect | string | `"NoSchedule"` |  |
| kube-prometheus-stack.kube-state-metrics.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
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
| kube-prometheus-stack.kubeProxy.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.enabled | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.service.port | int | `10259` |  |
| kube-prometheus-stack.kubeScheduler.service.targetPort | int | `10259` |  |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.https | bool | `true` |  |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.insecureSkipVerify | bool | `true` |  |
| kube-prometheus-stack.kubeStateMetrics.enabled | bool | `true` |  |
| kube-prometheus-stack.kubelet.enabled | bool | `true` |  |
| kube-prometheus-stack.kubelet.serviceMonitor.cAdvisor | bool | `true` |  |
| kube-prometheus-stack.nodeExporter.enabled | bool | `true` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].action | string | `"replace"` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].regex | string | `"^(.*)$"` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].replacement | string | `"$1"` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].separator | string | `";"` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].sourceLabels[0] | string | `"__meta_kubernetes_pod_node_name"` |  |
| kube-prometheus-stack.nodeExporter.serviceMonitor.relabelings[0].targetLabel | string | `"node"` |  |
| kube-prometheus-stack.prometheus-node-exporter.rbac.pspEnabled | bool | `false` |  |
| kube-prometheus-stack.prometheus-node-exporter.resources.requests.cpu | string | `"20m"` |  |
| kube-prometheus-stack.prometheus-node-exporter.resources.requests.memory | string | `"16Mi"` |  |
| kube-prometheus-stack.prometheus.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.logFormat | string | `"json"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.portName | string | `"http-prometheus"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.limits.memory | string | `"3Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.cpu | string | `"500m"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory | string | `"512Mi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.retention | string | `"8d"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues | bool | `false` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage | string | `"16Gi"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName | string | `"ebs-sc-gp3-xfs"` |  |
| kube-prometheus-stack.prometheus.prometheusSpec.walCompression | bool | `true` |  |
| kube-prometheus-stack.prometheusOperator.admissionWebhooks.patch.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| kube-prometheus-stack.prometheusOperator.admissionWebhooks.patch.tolerations[0].effect | string | `"NoSchedule"` |  |
| kube-prometheus-stack.prometheusOperator.admissionWebhooks.patch.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| kube-prometheus-stack.prometheusOperator.enabled | bool | `true` |  |
| kube-prometheus-stack.prometheusOperator.logFormat | string | `"json"` |  |
| kube-prometheus-stack.prometheusOperator.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| kube-prometheus-stack.prometheusOperator.resources.limits.memory | string | `"64Mi"` |  |
| kube-prometheus-stack.prometheusOperator.resources.requests.cpu | string | `"20m"` |  |
| kube-prometheus-stack.prometheusOperator.resources.requests.memory | string | `"32Mi"` |  |
| kube-prometheus-stack.prometheusOperator.tolerations[0].effect | string | `"NoSchedule"` |  |
| kube-prometheus-stack.prometheusOperator.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| prometheus-adapter.enabled | bool | `true` |  |
| prometheus-adapter.logLevel | int | `1` |  |
| prometheus-adapter.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| prometheus-adapter.prometheus.url | string | `"http://metrics-kube-prometheus-st-prometheus"` |  |
| prometheus-adapter.rules.default | bool | `false` |  |
| prometheus-adapter.rules.resource.cpu.containerLabel | string | `"container"` |  |
| prometheus-adapter.rules.resource.cpu.containerQuery | string | `"sum(irate(container_cpu_usage_seconds_total{<<.LabelMatchers>>,container!=\"POD\",container!=\"\",pod!=\"\"}[5m])) by (<<.GroupBy>>)"` |  |
| prometheus-adapter.rules.resource.cpu.nodeQuery | string | `"sum(1 - irate(node_cpu_seconds_total{mode=\"idle\"}[5m]) * on(namespace, pod) group_left(node) node_namespace_pod:kube_pod_info:{<<.LabelMatchers>>}) by (<<.GroupBy>>)"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.namespace.resource | string | `"namespace"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.node.resource | string | `"node"` |  |
| prometheus-adapter.rules.resource.cpu.resources.overrides.pod.resource | string | `"pod"` |  |
| prometheus-adapter.rules.resource.memory.containerLabel | string | `"container"` |  |
| prometheus-adapter.rules.resource.memory.containerQuery | string | `"sum(container_memory_working_set_bytes{<<.LabelMatchers>>,container!=\"POD\",container!=\"\",pod!=\"\"}) by (<<.GroupBy>>)"` |  |
| prometheus-adapter.rules.resource.memory.nodeQuery | string | `"sum(node_memory_MemTotal_bytes{job=\"node-exporter\",<<.LabelMatchers>>} - node_memory_MemAvailable_bytes{job=\"node-exporter\",<<.LabelMatchers>>}) by (<<.GroupBy>>)"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.namespace.resource | string | `"namespace"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.node.resource | string | `"node"` |  |
| prometheus-adapter.rules.resource.memory.resources.overrides.pod.resource | string | `"pod"` |  |
| prometheus-adapter.rules.resource.window | string | `"5m"` |  |
| prometheus-adapter.tolerations[0].effect | string | `"NoSchedule"` |  |
| prometheus-adapter.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |

# Dashboards

## Alertmanager
- https://grafana.com/api/dashboards/9578/revisions/4/download
## Prometheus
- https://grafana.com/api/dashboards/3662/revisions/2/download
