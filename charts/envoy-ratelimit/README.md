# envoy-ratelimit

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Envoy gobal ratelimiting service - part of KubeZero

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.31.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| descriptors.ingress | list | `[]` |  |
| descriptors.privateIngress | list | `[]` |  |
| failureModeDeny | bool | `false` |  |
| image.repository | string | `"envoyproxy/ratelimit"` |  |
| image.tag | string | `"38f01982"` |  |
| localCacheSize | int | `1048576` |  |
| log.format | string | `"json"` |  |
| log.level | string | `"warn"` |  |
| metrics.enabled | bool | `false` |  |
