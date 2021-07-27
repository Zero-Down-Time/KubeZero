# kubezero-redis

![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for Redis HA

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | redis | 12.1.1 |
| https://charts.bitnami.com/bitnami | redis-cluster | 4.1.0 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| istio.enabled | bool | `false` |  |
| redis-cluster.cluster.nodes | int | `2` |  |
| redis-cluster.cluster.replicas | int | `1` |  |
| redis-cluster.enabled | bool | `false` |  |
| redis-cluster.metrics.enabled | bool | `false` |  |
| redis-cluster.metrics.serviceMonitor.enabled | bool | `false` |  |
| redis-cluster.metrics.serviceMonitor.selector.release | string | `"metrics"` |  |
| redis-cluster.persistence.enabled | bool | `false` |  |
| redis-cluster.redisPort | int | `6379` |  |
| redis-cluster.usePassword | bool | `false` |  |
| redis.cluster.slaveCount | int | `0` |  |
| redis.enabled | bool | `false` |  |
| redis.master.persistence.enabled | bool | `false` |  |
| redis.metrics.enabled | bool | `false` |  |
| redis.metrics.serviceMonitor.enabled | bool | `false` |  |
| redis.metrics.serviceMonitor.selector.release | string | `"metrics"` |  |
| redis.redisPort | int | `6379` |  |
| redis.usePassword | bool | `false` |  |

# Dashboards
https://grafana.com/grafana/dashboards/11835

## Redis

# Resources
- https://ot-container-kit.github.io/redis-operator/
- https://github.com/helm/charts/tree/master/stable/redis
- https://github.com/rustudorcalin/deploying-redis-cluster
-
