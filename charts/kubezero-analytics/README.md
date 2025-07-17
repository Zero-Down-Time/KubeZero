# kubezero-analytics

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.1](https://img.shields.io/badge/AppVersion-3.0.1-informational?style=flat-square)

KubeZero Analytics module based on Plausible

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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| plausible.affinity | object | `{}` |  |
| plausible.baseURL | string | `"http://plausible-analytics.local"` |  |
| plausible.clickhouseDatabaseURL | string | `"http://clickhouse:password@plausible-analytics-clickhouse:8123/plausible_events_db"` |  |
| plausible.clickhouseFlushIntervalMS | string | `""` |  |
| plausible.clickhouseMaxBufferSize | string | `""` |  |
| plausible.databaseCA | string | `nil` |  |
| plausible.databaseURL | string | `"postgres://postgres:postgres@plausible-analytics-postgresql:5432/plausible_db"` |  |
| plausible.disableRegistration | bool | `false` |  |
| plausible.enabled | bool | `false` |  |
| plausible.extraEnv | list | `[]` |  |
| plausible.extraVolumeMounts | list | `[]` |  |
| plausible.extraVolumes | list | `[]` |  |
| plausible.extra_geolocation.enabled | bool | `false` |  |
| plausible.extra_geolocation.geolite2CountryDB | string | `""` |  |
| plausible.extra_geolocation.geonamesSourceFile | string | `""` |  |
| plausible.extra_geolocation.maxmind.edition | string | `""` |  |
| plausible.extra_geolocation.maxmind.licenseKey | string | `""` |  |
| plausible.fullnameOverride | string | `""` |  |
| plausible.google.clientID | string | `nil` |  |
| plausible.google.clientSecret | string | `nil` |  |
| plausible.google.enabled | bool | `false` |  |
| plausible.image.pullPolicy | string | `"IfNotPresent"` |  |
| plausible.image.repository | string | `"ghcr.io/plausible/community-edition"` |  |
| plausible.imagePullSecrets | list | `[]` |  |
| plausible.labels | object | `{}` |  |
| plausible.listenIP | string | `"0.0.0.0"` |  |
| plausible.livenessProbe.httpGet.path | string | `"/"` |  |
| plausible.livenessProbe.httpGet.port | string | `"http"` |  |
| plausible.livenessProbe.initialDelaySeconds | int | `30` |  |
| plausible.logFailedLoginAttempts | bool | `false` |  |
| plausible.mailer.adapter | string | `""` |  |
| plausible.mailer.email | string | `""` |  |
| plausible.mailer.enabled | bool | `false` |  |
| plausible.mailer.mailgun.apiKey | string | `""` |  |
| plausible.mailer.mailgun.baseURI | string | `""` |  |
| plausible.mailer.mailgun.domain | string | `""` |  |
| plausible.mailer.mandrillApiKey | string | `""` |  |
| plausible.mailer.postmarkApiKey | string | `""` |  |
| plausible.mailer.sendgridApiKey | string | `""` |  |
| plausible.mailer.smtp.auth | bool | `false` |  |
| plausible.mailer.smtp.host | string | `""` |  |
| plausible.mailer.smtp.password | string | `""` |  |
| plausible.mailer.smtp.port | string | `""` |  |
| plausible.mailer.smtp.retries | string | `""` |  |
| plausible.mailer.smtp.ssl | bool | `false` |  |
| plausible.mailer.smtp.username | string | `""` |  |
| plausible.nameOverride | string | `""` |  |
| plausible.nodeSelector | object | `{}` |  |
| plausible.podAnnotations | object | `{}` |  |
| plausible.podSecurityContext | object | `{}` |  |
| plausible.readinessProbe.httpGet.path | string | `"/"` |  |
| plausible.readinessProbe.httpGet.port | string | `"http"` |  |
| plausible.readinessProbe.initialDelaySeconds | int | `30` |  |
| plausible.replicaCount | int | `1` |  |
| plausible.resources | object | `{}` |  |
| plausible.secret.create | bool | `true` |  |
| plausible.secret.existingSecret | string | `""` |  |
| plausible.secretKeyBase | string | `""` |  |
| plausible.securityContext | object | `{}` |  |
| plausible.service.port | int | `80` |  |
| plausible.service.type | string | `"ClusterIP"` |  |
| plausible.tolerations | list | `[]` |  |
| plausible.totpVaultKey | string | `"dsxvbn3jxDd16az2QpsX5B8O+llxjQ2SJE2i5Bzx38I="` |  |

# Plausible
- https://plausible.io

## Resources
- https://github.com/IMIO/helm-plausible-analytics/tree/main
