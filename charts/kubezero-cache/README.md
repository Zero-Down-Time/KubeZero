# kubezero-cache

![Version: 0.2.4](https://img.shields.io/badge/Version-0.2.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| https://ot-container-kit.github.io/helm-charts | redis | 0.16.8 |
| https://ot-container-kit.github.io/helm-charts | redis-cluster | 0.17.3 |
| https://ot-container-kit.github.io/helm-charts | redis-replication | 0.16.11 |
| https://ot-container-kit.github.io/helm-charts | redis-sentinel | 0.16.11 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| istio.enabled | bool | `false` |  |
| istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| istio.url | string | `"external-servicename"` |  |
| redis-cluster.enabled | bool | `false` |  |
| redis-cluster.externalConfig.data | string | `"cluster-config-file /data/nodes.conf\n"` |  |
| redis-cluster.externalConfig.enabled | bool | `true` |  |
| redis-cluster.redisCluster.enableMasterSlaveAntiAffinity | bool | `true` |  |
| redis-cluster.redisCluster.follower.pdb.enabled | bool | `true` |  |
| redis-cluster.redisCluster.leader.pdb.enabled | bool | `true` |  |
| redis-cluster.redisExporter.enabled | bool | `false` |  |
| redis-cluster.serviceMonitor.enabled | bool | `false` |  |
| redis-cluster.storageSpec.keepAfterDelete | bool | `true` |  |
| redis-cluster.storageSpec.nodeConfVolume | bool | `false` |  |
| redis-replication.enabled | bool | `false` |  |
| redis-replication.pdb.enabled | bool | `true` |  |
| redis-replication.redisExporter.enabled | bool | `false` |  |
| redis-replication.redisReplication.service.additional.enabled | bool | `false` |  |
| redis-replication.redisReplication.tag | string | `"v8.0.3"` |  |
| redis-replication.redisVault.enabled | bool | `false` |  |
| redis-replication.redisVault.env | list | `[]` |  |
| redis-replication.redisVault.image.repository | string | `"public.ecr.aws/zero-downtime/redis-vault"` |  |
| redis-replication.redisVault.image.tag | string | `"v0.1.6"` |  |
| redis-replication.redisVault.resources.requests.cpu | string | `"10m"` |  |
| redis-replication.redisVault.resources.requests.memory | string | `"16Mi"` |  |
| redis-replication.serviceMonitor.enabled | bool | `false` |  |
| redis-replication.storageSpec.keepAfterDelete | bool | `true` |  |
| redis-sentinel.enabled | bool | `false` |  |
| redis-sentinel.pdb.enabled | bool | `true` |  |
| redis-sentinel.redisExporter.enabled | bool | `false` |  |
| redis-sentinel.redisSentinel.resources.requests.cpu | string | `"10m"` |  |
| redis-sentinel.redisSentinel.resources.requests.memory | string | `"16Mi"` |  |
| redis-sentinel.redisSentinel.service.additional.enabled | bool | `false` |  |
| redis-sentinel.redisSentinel.tag | string | `"v8.0.3"` |  |
| redis-sentinel.redisSentinelConfig.announceHostnames | string | `"yes"` |  |
| redis-sentinel.redisSentinelConfig.downAfterMilliseconds | string | `"10000"` |  |
| redis-sentinel.redisSentinelConfig.failoverTimeout | string | `"60000"` |  |
| redis-sentinel.redisSentinelConfig.resolveHostnames | string | `"yes"` |  |
| redis-sentinel.serviceMonitor.enabled | bool | `false` |  |
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
