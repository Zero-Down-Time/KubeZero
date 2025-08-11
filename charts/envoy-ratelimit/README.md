# envoy-ratelimit

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| descriptors.ingress[0].descriptors[0].key | string | `"remote_address"` |  |
| descriptors.ingress[0].descriptors[0].rate_limit.requests_per_unit | int | `60` |  |
| descriptors.ingress[0].descriptors[0].rate_limit.unit | string | `"minute"` |  |
| descriptors.ingress[0].key | string | `"sourceIp"` |  |
| descriptors.ingress[0].value | string | `"sixtyPerMinute"` |  |
| descriptors.ingress[1].descriptors[0].key | string | `"remote_address"` |  |
| descriptors.ingress[1].descriptors[0].rate_limit.unlimited | bool | `true` |  |
| descriptors.ingress[1].descriptors[0].value | string | `"10.*"` |  |
| descriptors.ingress[1].descriptors[1].key | string | `"remote_address"` |  |
| descriptors.ingress[1].descriptors[1].rate_limit.unlimited | bool | `true` |  |
| descriptors.ingress[1].descriptors[1].value | string | `"172.16.*"` |  |
| descriptors.ingress[1].descriptors[2].key | string | `"remote_address"` |  |
| descriptors.ingress[1].descriptors[2].rate_limit.requests_per_unit | int | `10` |  |
| descriptors.ingress[1].descriptors[2].rate_limit.unit | string | `"second"` |  |
| descriptors.ingress[1].key | string | `"sourceIp"` |  |
| descriptors.ingress[1].value | string | `"tenPerSecond"` |  |
| descriptors.ingress[2].descriptors[0].key | string | `"userAgent"` |  |
| descriptors.ingress[2].descriptors[0].rate_limit.requests_per_unit | int | `180` |  |
| descriptors.ingress[2].descriptors[0].rate_limit.unit | string | `"minute"` |  |
| descriptors.ingress[2].key | string | `"headers"` |  |
| descriptors.ingress[2].value | string | `"180PerMinute"` |  |
| descriptors.privateIngress[0].descriptors[0].key | string | `"remote_address"` |  |
| descriptors.privateIngress[0].descriptors[0].rate_limit.requests_per_unit | int | `60` |  |
| descriptors.privateIngress[0].descriptors[0].rate_limit.unit | string | `"minute"` |  |
| descriptors.privateIngress[0].key | string | `"sourceIp"` |  |
| descriptors.privateIngress[0].value | string | `"sixtyPerMinute"` |  |
| descriptors.privateIngress[1].descriptors[0].key | string | `"remote_address"` |  |
| descriptors.privateIngress[1].descriptors[0].rate_limit.requests_per_unit | int | `10` |  |
| descriptors.privateIngress[1].descriptors[0].rate_limit.unit | string | `"second"` |  |
| descriptors.privateIngress[1].key | string | `"sourceIp"` |  |
| descriptors.privateIngress[1].value | string | `"tenPerSecond"` |  |
| descriptors.privateIngress[2].descriptors[0].key | string | `"userAgent"` |  |
| descriptors.privateIngress[2].descriptors[0].rate_limit.requests_per_unit | int | `180` |  |
| descriptors.privateIngress[2].descriptors[0].rate_limit.unit | string | `"minute"` |  |
| descriptors.privateIngress[2].key | string | `"headers"` |  |
| descriptors.privateIngress[2].value | string | `"180PerMinute"` |  |
| failureModeDeny | bool | `false` |  |
| image.repository | string | `"envoyproxy/ratelimit"` |  |
| image.tag | string | `"a90e0e5d"` |  |
| localCacheSize | int | `1048576` |  |
| log.format | string | `"json"` |  |
| log.level | string | `"warn"` |  |
| metrics.enabled | bool | `false` |  |
