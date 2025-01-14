# kubezero-graph

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero GraphQL and GraphDB

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.29.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | >= 0.2.1 |
| https://helm.neo4j.com/neo4j | neo4j | 5.26.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| neo4j.disableLookups | bool | `true` |  |
| neo4j.enabled | bool | `false` |  |
| neo4j.neo4j.name | string | `"test-db"` |  |
| neo4j.serviceMonitor.enabled | bool | `false` |  |
| neo4j.services.neo4j.enabled | bool | `false` |  |
| neo4j.volumes.data.mode | string | `"defaultStorageClass"` |  |

# Dashboards
https://grafana.com/grafana/dashboards/11835

## Redis

# Resources
- https://ot-container-kit.github.io/redis-operator/
- https://github.com/helm/charts/tree/master/stable/redis
- https://github.com/rustudorcalin/deploying-redis-cluster
-
