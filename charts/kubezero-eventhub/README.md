# kubezero-eventhub

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.5.0](https://img.shields.io/badge/AppVersion-v1.5.0-informational?style=flat-square)

KubeZero cluster-internal event/notification hub (apprise-api)

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.34.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| env.APPRISE_ALLOW_SERVICES | string | `"slack"` |  |
| env.APPRISE_API_ONLY | string | `"yes"` |  |
| env.APPRISE_CONFIG_LOCK | string | `"yes"` |  |
| env.APPRISE_STATEFUL_MODE | string | `"simple"` |  |
| env.APPRISE_WORKER_COUNT | string | `"1"` |  |
| existingSecret | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"docker.io/caronc/apprise"` |  |
| image.tag | string | `""` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.from[0].namespaceSelector | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| replicas | int | `1` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| secretConfig | object | `{}` |  |
| service.port | int | `8000` |  |
| tolerations | list | `[]` |  |
