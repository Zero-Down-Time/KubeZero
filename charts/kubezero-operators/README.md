# kubezero-operators

![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Various operators supported by KubeZero

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
| https://charts.bitnami.com/bitnami | rabbitmq-cluster-operator | 4.4.25 |
| https://cloudnative-pg.github.io/charts | cloudnative-pg | 0.24.0 |
| https://docs.altinity.com/clickhouse-operator | altinity-clickhouse-operator | 0.25.2 |
| https://helm.elastic.co | eck-operator | 3.0.0 |
| oci://quay.io/strimzi-helm | strimzi-kafka-operator | 0.47.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| altinity-clickhouse-operator.dashboards.additionalLabels.grafana_dashboard | string | `"1"` |  |
| altinity-clickhouse-operator.dashboards.enabled | bool | `false` |  |
| altinity-clickhouse-operator.enabled | bool | `false` |  |
| altinity-clickhouse-operator.metrics.enabled | bool | `false` |  |
| altinity-clickhouse-operator.operator.resources.limits.memory | string | `"128Mi"` |  |
| altinity-clickhouse-operator.operator.resources.requests.cpu | string | `"10m"` |  |
| altinity-clickhouse-operator.operator.resources.requests.memory | string | `"32Mi"` |  |
| altinity-clickhouse-operator.serviceMonitor.enabled | bool | `false` |  |
| cloudnative-pg.config.data.CLUSTERS_ROLLOUT_DELAY | string | `"60"` |  |
| cloudnative-pg.config.data.ENABLE_INSTANCE_MANAGER_INPLACE_UPDATES | string | `"true"` |  |
| cloudnative-pg.config.data.INSTANCES_ROLLOUT_DELAY | string | `"10"` |  |
| cloudnative-pg.enabled | bool | `false` |  |
| cloudnative-pg.monitoring.grafanaDashboard.create | bool | `false` |  |
| cloudnative-pg.monitoring.podMonitorEnabled | bool | `false` |  |
| cloudnative-pg.resources.limits.memory | string | `"128Mi"` |  |
| cloudnative-pg.resources.requests.cpu | string | `"10m"` |  |
| cloudnative-pg.resources.requests.memory | string | `"32Mi"` |  |
| eck-operator.enabled | bool | `false` |  |
| eck-operator.installCRDs | bool | `false` |  |
| rabbitmq-cluster-operator.clusterOperator.metrics.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.clusterOperator.metrics.serviceMonitor.enabled | bool | `true` |  |
| rabbitmq-cluster-operator.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.msgTopologyOperator.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.msgTopologyOperator.metrics.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.msgTopologyOperator.metrics.serviceMonitor.enabled | bool | `true` |  |
| rabbitmq-cluster-operator.useCertManager | bool | `true` |  |
| strimzi-kafka-operator.enabled | bool | `false` |  |
| strimzi-kafka-operator.leaderElection.enable | bool | `false` |  |
| strimzi-kafka-operator.monitoring.podMonitorEnabled | bool | `false` |  |
| strimzi-kafka-operator.resources.requests.cpu | string | `"20m"` |  |
| strimzi-kafka-operator.resources.requests.memory | string | `"256Mi"` |  |
| strimzi-kafka-operator.revisionHistoryLimit | int | `2` |  |
| strimzi-kafka-operator.watchAnyNamespace | bool | `true` |  |

## Resources
