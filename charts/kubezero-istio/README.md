# kubezero-istio

![Version: 0.30.3](https://img.shields.io/badge/Version-0.30.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for Istio

Installs the Istio control plane

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.34.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | envoy-ratelimit | 0.1.3 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://istio-release.storage.googleapis.com/charts | base | 1.30.3 |
| https://istio-release.storage.googleapis.com/charts | istiod | 1.30.3 |
| https://kiali.org/helm-charts | kiali-server | 2.29.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| envoy-ratelimit.enabled | bool | `false` |  |
| global.defaultPodDisruptionBudget.enabled | bool | `false` |  |
| global.logAsJson | bool | `true` |  |
| global.nativeNftables | bool | `true` |  |
| global.networkPolicy.enabled | bool | `true` |  |
| global.variant | string | `"distroless"` |  |
| istiod.autoscaleEnabled | bool | `false` |  |
| istiod.meshConfig.accessLogEncoding | string | `"JSON"` |  |
| istiod.meshConfig.accessLogFile | string | `"/dev/stdout"` |  |
| istiod.meshConfig.accessLogFormat | string | `"{\n  \"start_time\": \"%START_TIME%\",\n  \"method\": \"%REQ(:METHOD)%\",\n  \"path\": \"%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%\",\n  \"protocol\": \"%PROTOCOL%\",\n  \"response_code\": \"%RESPONSE_CODE%\",\n  \"response_flags\": \"%RESPONSE_FLAGS%\",\n  \"response_code_details\": \"%RESPONSE_CODE_DETAILS%\",\n  \"connection_termination_details\": \"%CONNECTION_TERMINATION_DETAILS%\",\n  \"upstream_transport_failure_reason\": \"%UPSTREAM_TRANSPORT_FAILURE_REASON%\",\n  \"bytes_received\": \"%BYTES_RECEIVED%\",\n  \"bytes_sent\": \"%BYTES_SENT%\",\n  \"duration\": \"%DURATION%\",\n  \"upstream_service_time\": \"%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%\",\n  \"x_forwarded_for\": \"%REQ(X-FORWARDED-FOR)%\",\n  \"user_agent\": \"%REQ(USER-AGENT)%\",\n  \"request_id\": \"%REQ(X-REQUEST-ID)%\",\n  \"authority\": \"%REQ(:AUTHORITY)%\",\n  \"upstream_host\": \"%UPSTREAM_HOST%\",\n  \"upstream_cluster\": \"%UPSTREAM_CLUSTER%\",\n  \"upstream_local_address\": \"%UPSTREAM_LOCAL_ADDRESS%\",\n  \"downstream_local_address\": \"%DOWNSTREAM_LOCAL_ADDRESS%\",\n  \"downstream_remote_address\": \"%DOWNSTREAM_REMOTE_ADDRESS%\",\n  \"requested_server_name\": \"%REQUESTED_SERVER_NAME%\",\n  \"route_name\": \"%ROUTE_NAME%\",\n  \"log_type\": \"accessLog\",\n  \"connection_id\": \"%CONNECTION_ID%\",\n  \"ja4\": \"%TLS_JA4_FINGERPRINT%\"\n}\n"` |  |
| istiod.meshConfig.tcpKeepalive.interval | string | `"60s"` |  |
| istiod.meshConfig.tcpKeepalive.time | string | `"120s"` |  |
| istiod.replicaCount | int | `1` |  |
| istiod.resources.limits.memory | string | `"256Mi"` |  |
| istiod.resources.requests.cpu | string | `"100m"` |  |
| istiod.resources.requests.memory | string | `"128Mi"` |  |
| istiod.telemetry.dashboards | bool | `false` |  |
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
