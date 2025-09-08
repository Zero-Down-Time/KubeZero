# kubezero-graph

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero GraphQL and GraphDB

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
| https://helm.neo4j.com/neo4j | neo4j | 2025.7.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| neo4j.backup.backoffLimit | int | `1` |  |
| neo4j.backup.concurrencyPolicy | string | `"Forbid"` |  |
| neo4j.backup.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| neo4j.backup.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| neo4j.backup.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| neo4j.backup.enabled | bool | `false` |  |
| neo4j.backup.env.AWS_DEFAULT_REGION | string | `""` |  |
| neo4j.backup.env.AWS_REGION | string | `""` |  |
| neo4j.backup.env.BACKUP_TEMP_DIR | string | `""` |  |
| neo4j.backup.env.BUCKET_NAME | string | `""` |  |
| neo4j.backup.env.CLOUD_PROVIDER | string | `""` |  |
| neo4j.backup.env.COMPRESS | string | `"true"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_COUNTS | string | `"true"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_DATABASE | string | `""` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_ENABLE | string | `"false"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_GRAPH | string | `"true"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_INDEXES | string | `"true"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_MAXOFFHEAPMEMORY | string | `""` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_PROPERTYOWNERS | string | `"true"` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_TEMP_DIR | string | `""` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_THREADS | string | `""` |  |
| neo4j.backup.env.CONSISTENCY_CHECK_VERBOSE | string | `"true"` |  |
| neo4j.backup.env.CREDENTIAL_PATH | string | `"/credentials/"` |  |
| neo4j.backup.env.DATABASE | string | `"neo4j,system"` |  |
| neo4j.backup.env.DATABASE_BACKUP_ENDPOINTS | string | `""` |  |
| neo4j.backup.env.DATABASE_BACKUP_PORT | string | `"6362"` |  |
| neo4j.backup.env.DATABASE_CLUSTER_DOMAIN | string | `"cluster.local"` |  |
| neo4j.backup.env.DATABASE_NAMESPACE | string | `""` |  |
| neo4j.backup.env.DATABASE_SERVICE_IP | string | `""` |  |
| neo4j.backup.env.DATABASE_SERVICE_NAME | string | `""` |  |
| neo4j.backup.env.HEAP_SIZE | string | `""` |  |
| neo4j.backup.env.INCLUDE_METADATA | string | `"all"` |  |
| neo4j.backup.env.KEEP_BACKUP_FILES | string | `"false"` |  |
| neo4j.backup.env.KEEP_FAILED | string | `"false"` |  |
| neo4j.backup.env.PAGE_CACHE | string | `""` |  |
| neo4j.backup.env.PARALLEL_RECOVERY | string | `"false"` |  |
| neo4j.backup.env.PREFER_DIFF_AS_PARENT | string | `"true"` |  |
| neo4j.backup.env.S3_CA_CERT_PATH | string | `""` |  |
| neo4j.backup.env.S3_FORCE_PATH_STYLE | string | `"true"` |  |
| neo4j.backup.env.S3_SIGNATURE_VERSION | string | `""` |  |
| neo4j.backup.env.S3_SKIP_VERIFY | string | `"false"` |  |
| neo4j.backup.env.TYPE | string | `"AUTO"` |  |
| neo4j.backup.env.VERBOSE | string | `"true"` |  |
| neo4j.backup.failedJobsHistoryLimit | int | `1` |  |
| neo4j.backup.image.repository | string | `"neo4j/helm-charts-backup"` |  |
| neo4j.backup.image.tag | string | `"2025.07.1"` |  |
| neo4j.backup.labels | object | `{}` |  |
| neo4j.backup.name | string | `"graph-backup"` |  |
| neo4j.backup.podAnnotations | object | `{}` |  |
| neo4j.backup.podLabels | object | `{}` |  |
| neo4j.backup.resources | object | `{}` |  |
| neo4j.backup.restartPolicy | string | `"Never"` |  |
| neo4j.backup.schedule | string | `"0 * * * *"` |  |
| neo4j.backup.securityContext.fsGroup | int | `7474` |  |
| neo4j.backup.securityContext.fsGroupChangePolicy | string | `"Always"` |  |
| neo4j.backup.securityContext.runAsGroup | int | `7474` |  |
| neo4j.backup.securityContext.runAsNonRoot | bool | `true` |  |
| neo4j.backup.securityContext.runAsUser | int | `7474` |  |
| neo4j.backup.serviceAccount.annotations | object | `{}` |  |
| neo4j.backup.serviceAccount.name | string | `""` |  |
| neo4j.backup.successfulJobsHistoryLimit | int | `1` |  |
| neo4j.backup.volumeMounts[0].mountPath | string | `"/backups"` |  |
| neo4j.backup.volumeMounts[0].name | string | `"backup"` |  |
| neo4j.backup.volumes[0].emptyDir | object | `{}` |  |
| neo4j.backup.volumes[0].name | string | `"backup"` |  |
| neo4j.disableLookups | bool | `true` |  |
| neo4j.enabled | bool | `false` |  |
| neo4j.neo4j.name | string | `"test-db"` |  |
| neo4j.neo4j.password | string | `"secret"` |  |
| neo4j.neo4j.passwordFromSecret | string | `"neo4j-admin"` |  |
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
