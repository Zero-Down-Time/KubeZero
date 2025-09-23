# kubezero-cache

![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Cache module

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
| https://ot-container-kit.github.io/helm-charts | redis | 0.16.6 |
| https://ot-container-kit.github.io/helm-charts | redis-cluster | 0.17.1 |
| https://ot-container-kit.github.io/helm-charts | redis-replication | 0.16.9 |
| https://ot-container-kit.github.io/helm-charts | redis-sentinel | 0.16.10 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| istio.enabled | bool | `false` |  |
| redis-cluster.enabled | bool | `false` |  |
| redis-cluster.redisCluster.enableMasterSlaveAntiAffinity | bool | `true` |  |
| redis-cluster.redisCluster.follower.pdb.enabled | bool | `true` |  |
| redis-cluster.redisCluster.leader.pdb.enabled | bool | `true` |  |
| redis-cluster.redisExporter.enabled | bool | `false` |  |
| redis-cluster.serviceMonitor.enabled | bool | `false` |  |
| redis-cluster.storageSpec.nodeConfVolume | bool | `false` |  |
| redis-replication.enabled | bool | `false` |  |
| redis-replication.pdb.enabled | bool | `true` |  |
| redis-replication.redisReplication.service.additional.enabled | bool | `false` |  |
| redis-replication.redisReplication.tag | string | `"v8.0.3"` |  |
| redis-sentinel.enabled | bool | `false` |  |
| redis-sentinel.pdb.enabled | bool | `true` |  |
| redis-sentinel.redisSentinel.service.additional.enabled | bool | `false` |  |
| redis-sentinel.redisSentinel.tag | string | `"v8.0.3"` |  |
| redis.enabled | bool | `false` |  |
| redis.redisExporter.enabled | bool | `false` |  |
| redis.redisStandalone.service.additional.enabled | bool | `false` |  |
| redis.redisStandalone.service.headless.enabled | bool | `false` |  |
| redis.redisStandalone.tag | string | `"v8.0.3"` |  |
| redis.serviceMonitor.enabled | bool | `false` |  |
| redis.storageSpec | string | `nil` |  |
| snapshotgroups | object | `{}` |  |

# Dashboards
https://grafana.com/grafana/dashboards/11835

## Redis

# Resources
- https://ot-container-kit.github.io/redis-operator/
- https://github.com/helm/charts/tree/master/stable/redis
- https://github.com/rustudorcalin/deploying-redis-cluster
-
