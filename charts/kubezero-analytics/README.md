# kubezero-analytics

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Analytics module

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
| https://charts.christianhuth.de | umami | 5.0.8 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| umami.database.databaseUrlKey | string | `"databaseUrl"` |  |
| umami.database.existingSecret | string | `"umami-pg"` |  |
| umami.enabled | bool | `false` |  |
| umami.externalDatabase.type | string | `"postgresql"` |  |
| umami.istio.enabled | bool | `false` |  |
| umami.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| umami.istio.url | string | `"umami.example.com"` |  |
| umami.pg.auth.password | string | `"umami"` |  |
| umami.pg.auth.username | string | `"umami"` |  |
| umami.pg.backup.enabled | bool | `false` |  |
| umami.pg.backup.volumeSnapshotClassName | string | `"openebs-lvm-snapshots"` |  |
| umami.postgresql.enabled | bool | `false` |  |
| umami.revisionHistoryLimit | int | `2` |  |

# Plausible
- https://plausible.io

## Resources
- https://github.com/IMIO/helm-plausible-analytics/tree/main
