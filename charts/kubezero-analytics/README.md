# kubezero-analytics

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| https://imio.github.io/helm-charts | plausible-analytics | 0.4.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| plausible-analytics.clickhouse.enabled | bool | `false` |  |
| plausible-analytics.enabled | bool | `false` |  |
| plausible-analytics.plausibleInitContainers.enabled | bool | `false` |  |
| plausible-analytics.postgresql.enabled | bool | `false` |  |

# Plausible
- https://plausible.io

## Resources
- https://github.com/IMIO/helm-plausible-analytics/tree/main
