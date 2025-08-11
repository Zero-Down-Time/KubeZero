# kubezero-istio

![Version: 0.26.3](https://img.shields.io/badge/Version-0.26.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for Istio

Installs the Istio control plane

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | envoy-ratelimit | 0.1.2 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://istio-release.storage.googleapis.com/charts | base | 1.26.3 |
| https://istio-release.storage.googleapis.com/charts | istiod | 1.26.3 |
| https://kiali.org/helm-charts | kiali-server | 2.13.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| envoy-ratelimit.enabled | bool | `false` |  |
| global.defaultPodDisruptionBudget.enabled | bool | `false` |  |
| global.logAsJson | bool | `true` |  |
| global.variant | string | `"distroless"` |  |
| istiod.autoscaleEnabled | bool | `false` |  |
| istiod.meshConfig.accessLogEncoding | string | `"JSON"` |  |
| istiod.meshConfig.accessLogFile | string | `"/dev/stdout"` |  |
| istiod.meshConfig.tcpKeepalive.interval | string | `"60s"` |  |
| istiod.meshConfig.tcpKeepalive.time | string | `"120s"` |  |
| istiod.replicaCount | int | `1` |  |
| istiod.resources.limits.memory | string | `"256Mi"` |  |
| istiod.resources.requests.cpu | string | `"100m"` |  |
| istiod.resources.requests.memory | string | `"128Mi"` |  |
| istiod.telemetry.enabled | bool | `false` |  |
| kiali-server.auth.strategy | string | `"anonymous"` |  |
| kiali-server.deployment.ingress_enabled | bool | `false` |  |
| kiali-server.deployment.view_only_mode | bool | `true` |  |
| kiali-server.enabled | bool | `false` |  |
| kiali-server.external_services.custom_dashboards.enabled | bool | `false` |  |
| kiali-server.external_services.prometheus.url | string | `"http://metrics-kube-prometheus-st-prometheus.monitoring:9090"` |  |
| kiali-server.istio.enabled | bool | `false` |  |
| kiali-server.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| kiali-server.server.metrics_enabled | bool | `false` |  |

## Resources

- https://github.com/istio/istio/blob/master/manifests/profiles/default.yaml

### Grafana
- https://grafana.com/grafana/dashboards/7645
- https://grafana.com/grafana/dashboards/7639
- https://grafana.com/grafana/dashboards/7636
- https://grafana.com/grafana/dashboards/7630
- https://grafana.com/grafana/dashboards/11829
