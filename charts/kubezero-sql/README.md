# kubezero-sql

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for SQL databases, mariadb-galera

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.26.0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://charts.bitnami.com/bitnami | mariadb-galera | 14.0.10 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mariadb-galera.configurationConfigMap | string | `"{{ .Release.Name }}-mariadb-galera-configuration"` |  |
| mariadb-galera.db.user | string | `"mariadb"` |  |
| mariadb-galera.enabled | bool | `false` |  |
| mariadb-galera.istio.enabled | bool | `false` |  |
| mariadb-galera.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| mariadb-galera.istio.url | string | `"mariadb.example.com"` |  |
| mariadb-galera.metrics.enabled | bool | `false` |  |
| mariadb-galera.metrics.installDashboard | bool | `true` |  |
| mariadb-galera.metrics.prometheusRules.enabled | bool | `false` |  |
| mariadb-galera.metrics.serviceMonitor.enabled | bool | `false` |  |
| mariadb-galera.replicaCount | int | `2` |  |

# Changes

## MariaDB
- custom my.cnf, source: https://github.com/bitnami/charts/blob/70d602fea38010145c20e1ca59be06e4cf32bf80/bitnami/mariadb-galera/values.yaml#L261

## Resources

### MariaDB

