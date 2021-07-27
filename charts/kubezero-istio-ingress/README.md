# kubezero-istio-ingress

![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.10.2](https://img.shields.io/badge/AppVersion-1.10.2-informational?style=flat-square)

KubeZero Umbrella Chart for Istio based Ingress

Installs Istio Ingress Gateways, requires kubezero-istio to be installed !

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
|  | istio-ingress | 1.10.2 |
|  | istio-private-ingress | 1.10.2 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.arch.amd64 | int | `2` |  |
| global.defaultPodDisruptionBudget.enabled | bool | `false` |  |
| global.logAsJson | bool | `true` |  |
| global.priorityClassName | string | `"system-cluster-critical"` |  |
| istio-ingress.certificates[0].dnsNames | list | `[]` |  |
| istio-ingress.certificates[0].name | string | `"ingress-cert"` |  |
| istio-ingress.enabled | bool | `false` |  |
| istio-ingress.gateways.istio-ingressgateway.autoscaleEnabled | bool | `false` |  |
| istio-ingress.gateways.istio-ingressgateway.configVolumes[0].configMapName | string | `"istio-gateway-bootstrap-config"` |  |
| istio-ingress.gateways.istio-ingressgateway.configVolumes[0].mountPath | string | `"/etc/istio/custom-bootstrap"` |  |
| istio-ingress.gateways.istio-ingressgateway.configVolumes[0].name | string | `"custom-bootstrap-volume"` |  |
| istio-ingress.gateways.istio-ingressgateway.env.ISTIO_BOOTSTRAP_OVERRIDE | string | `"/etc/istio/custom-bootstrap/custom_bootstrap.json"` |  |
| istio-ingress.gateways.istio-ingressgateway.externalTrafficPolicy | string | `"Local"` |  |
| istio-ingress.gateways.istio-ingressgateway.nodeSelector."node.kubernetes.io/ingress.public" | string | `"30080_30443"` |  |
| istio-ingress.gateways.istio-ingressgateway.podAnnotations."proxy.istio.io/config" | string | `"{ \"terminationDrainDuration\": \"20s\" }"` |  |
| istio-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].key | string | `"app"` |  |
| istio-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].operator | string | `"In"` |  |
| istio-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| istio-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].values | string | `"istio-ingressgateway"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[0].name | string | `"status-port"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[0].nodePort | int | `30021` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[0].port | int | `15021` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[0].protocol | string | `"TCP"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[1].name | string | `"http2"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[1].nodePort | int | `30080` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[1].port | int | `80` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[1].protocol | string | `"TCP"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[1].targetPort | int | `8080` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[2].name | string | `"https"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[2].nodePort | int | `30443` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[2].port | int | `443` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[2].protocol | string | `"TCP"` |  |
| istio-ingress.gateways.istio-ingressgateway.ports[2].targetPort | int | `8443` |  |
| istio-ingress.gateways.istio-ingressgateway.replicaCount | int | `1` |  |
| istio-ingress.gateways.istio-ingressgateway.resources.limits.memory | string | `"512Mi"` |  |
| istio-ingress.gateways.istio-ingressgateway.resources.requests.cpu | string | `"50m"` |  |
| istio-ingress.gateways.istio-ingressgateway.resources.requests.memory | string | `"64Mi"` |  |
| istio-ingress.gateways.istio-ingressgateway.rollingMaxSurge | int | `1` |  |
| istio-ingress.gateways.istio-ingressgateway.rollingMaxUnavailable | int | `0` |  |
| istio-ingress.gateways.istio-ingressgateway.type | string | `"NodePort"` |  |
| istio-ingress.meshConfig.defaultConfig.proxyMetadata | string | `nil` |  |
| istio-ingress.proxyProtocol | bool | `false` |  |
| istio-ingress.telemetry.enabled | bool | `false` |  |
| istio-private-ingress.certificates[0].dnsNames | list | `[]` |  |
| istio-private-ingress.certificates[0].name | string | `"private-ingress-cert"` |  |
| istio-private-ingress.enabled | bool | `false` |  |
| istio-private-ingress.gateways.istio-ingressgateway.autoscaleEnabled | bool | `false` |  |
| istio-private-ingress.gateways.istio-ingressgateway.configVolumes[0].configMapName | string | `"istio-gateway-bootstrap-config"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.configVolumes[0].mountPath | string | `"/etc/istio/custom-bootstrap"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.configVolumes[0].name | string | `"custom-bootstrap-volume"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.env.ISTIO_BOOTSTRAP_OVERRIDE | string | `"/etc/istio/custom-bootstrap/custom_bootstrap.json"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.externalTrafficPolicy | string | `"Local"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.labels.app | string | `"istio-private-ingressgateway"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.labels.istio | string | `"private-ingressgateway"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.name | string | `"istio-private-ingressgateway"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.nodeSelector."node.kubernetes.io/ingress.private" | string | `"31080_31443"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.podAnnotations."proxy.istio.io/config" | string | `"{ \"terminationDrainDuration\": \"20s\" }"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].key | string | `"app"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].operator | string | `"In"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.podAntiAffinityLabelSelector[0].values | string | `"istio-private-ingressgateway"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[0].name | string | `"status-port"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[0].nodePort | int | `31021` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[0].port | int | `15021` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[0].protocol | string | `"TCP"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[1].name | string | `"http2"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[1].nodePort | int | `31080` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[1].port | int | `80` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[1].protocol | string | `"TCP"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[1].targetPort | int | `8080` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[2].name | string | `"https"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[2].nodePort | int | `31443` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[2].port | int | `443` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[2].protocol | string | `"TCP"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.ports[2].targetPort | int | `8443` |  |
| istio-private-ingress.gateways.istio-ingressgateway.replicaCount | int | `1` |  |
| istio-private-ingress.gateways.istio-ingressgateway.resources.limits.memory | string | `"512Mi"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.resources.requests.cpu | string | `"50m"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.resources.requests.memory | string | `"64Mi"` |  |
| istio-private-ingress.gateways.istio-ingressgateway.rollingMaxSurge | int | `1` |  |
| istio-private-ingress.gateways.istio-ingressgateway.rollingMaxUnavailable | int | `0` |  |
| istio-private-ingress.gateways.istio-ingressgateway.type | string | `"NodePort"` |  |
| istio-private-ingress.meshConfig.defaultConfig.proxyMetadata | string | `nil` |  |
| istio-private-ingress.proxyProtocol | bool | `false` |  |
| istio-private-ingress.telemetry.enabled | bool | `false` |  |

## Resources

- https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#IstioOperatorSpec
- https://github.com/istio/istio/blob/master/manifests/profiles/default.yaml
- https://istio.io/latest/docs/setup/install/standalone-operator/
