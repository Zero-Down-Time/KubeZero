# kubezero-istio-gateway

![Version: 0.27.3](https://img.shields.io/badge/Version-0.27.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for Istio gateways

Installs Istio Ingress Gateways, requires kubezero-istio to be installed !

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
| https://istio-release.storage.googleapis.com/charts | gateway | 1.27.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| certificates | list | `[]` |  |
| gateway.autoscaling.enabled | bool | `false` |  |
| gateway.autoscaling.maxReplicas | int | `4` |  |
| gateway.autoscaling.minReplicas | int | `1` |  |
| gateway.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| gateway.minReadySeconds | int | `10` |  |
| gateway.podAnnotations."proxy.istio.io/config" | string | `"{ \"terminationDrainDuration\": \"90s\" }"` |  |
| gateway.replicaCount | int | `1` |  |
| gateway.resources.limits.memory | string | `"512Mi"` |  |
| gateway.resources.requests.cpu | string | `"50m"` |  |
| gateway.resources.requests.memory | string | `"96Mi"` |  |
| gateway.service.externalTrafficPolicy | string | `"Local"` |  |
| gateway.service.type | string | `"NodePort"` |  |
| gateway.terminationGracePeriodSeconds | int | `120` |  |
| hardening.preserveExternalRequestId | bool | `false` |  |
| hardening.rejectUnderscoresHeaders | bool | `true` |  |
| hardening.unescapeSlashes | bool | `true` |  |
| httpFilter.grpcWeb | bool | `false` |  |
| proxyProtocol | bool | `true` |  |
| telemetry.enabled | bool | `false` |  |

## Resources

### Envoy Listener Filter - TCP KeepAlive
- https://github.com/cilium/cilium/blob/main/operator/pkg/model/translation/envoy_listener.go#L134

