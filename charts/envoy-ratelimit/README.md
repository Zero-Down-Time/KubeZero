# envoy-ratelimit

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| descriptors.ingress[0].key | string | `"remote_address"` |  |
| descriptors.ingress[0].rate_limit.requests_per_unit | int | `10` |  |
| descriptors.ingress[0].rate_limit.unit | string | `"second"` |  |
| descriptors.privateIngress[0].key | string | `"remote_address"` |  |
| descriptors.privateIngress[0].rate_limit.requests_per_unit | int | `10` |  |
| descriptors.privateIngress[0].rate_limit.unit | string | `"second"` |  |
| failureModeDeny | bool | `false` |  |
| localCacheSize | int | `1048576` |  |
| log.format | string | `"json"` |  |
| log.level | string | `"warn"` |  |
| metrics.enabled | bool | `true` |  |
