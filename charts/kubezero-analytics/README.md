# kubezero-analytics

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| https://charts.christianhuth.de | umami | 6.0.1 |

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
| umami.resources.requests.cpu | string | `"100m"` |  |
| umami.resources.requests.memory | string | `"256Mi"` |  |
| umami.revisionHistoryLimit | int | `2` |  |
| umami.umami.appSecret.existingSecret | string | `""` |  |
| umami.umami.appSecret.secret | string | `"examplereallysecretstring"` |  |
| umami.umami.cloudMode | string | `"1"` |  |
| umami.umami.collectApiEndpoint | string | `""` | Allows you to send metrics to a location different than the default `/api/send`. This is to help you avoid some ad-blockers. |
| umami.umami.disableBotCheck | string | `"0"` |  |
| umami.umami.disableLogin | string | `"1"` |  |
| umami.umami.enableTestConsole | string | `"0"` |  |
| umami.umami.logQuery | string | `"0"` |  |
| umami.umami.removeDisableLoginEnv | bool | `false` |  |
| umami.umami.removeTrailingSlash | string | `"0"` |  |

# Umami
- https://umami.is

## Resources
- https://www.rybbit.io/
