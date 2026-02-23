# kubezero-auth

![Version: 0.7.2](https://img.shields.io/badge/Version-0.7.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for all things Authentication and Identity management

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
| oci://ghcr.io/codecentric/helm-charts | keycloakx | 7.1.8 |

# Keycloak

## Operator

https://www.keycloak.org/operator/installation
https://github.com/keycloak/keycloak/tree/main/operator
https://github.com/aerogear/keycloak-metrics-spi
https://github.com/keycloak/keycloak-benchmark/tree/main/provision/minikube/keycloak/templates

## Resources
- https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| keycloakx.command[0] | string | `"/opt/keycloak/bin/kc.sh"` |  |
| keycloakx.command[1] | string | `"--verbose"` |  |
| keycloakx.command[2] | string | `"start"` |  |
| keycloakx.command[3] | string | `"--http-port=8080"` |  |
| keycloakx.command[4] | string | `"--spi-events-listener-jboss-logging-success-level=info"` |  |
| keycloakx.command[5] | string | `"--spi-events-listener-jboss-logging-error-level=warn"` |  |
| keycloakx.database.database | string | `"keycloak"` |  |
| keycloakx.database.existingSecret | string | `"keycloak-pg"` |  |
| keycloakx.database.existingSecretKey | string | `"password"` |  |
| keycloakx.database.hostname | string | `"keycloak-pg-rw"` |  |
| keycloakx.database.port | int | `5432` |  |
| keycloakx.database.username | string | `"keycloak"` |  |
| keycloakx.database.vendor | string | `"postgres"` |  |
| keycloakx.enabled | bool | `false` |  |
| keycloakx.http.relativePath | string | `"/"` |  |
| keycloakx.istio.admin.enabled | bool | `false` |  |
| keycloakx.istio.admin.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| keycloakx.istio.admin.url | string | `""` |  |
| keycloakx.istio.auth.enabled | bool | `false` |  |
| keycloakx.istio.auth.gateway | string | `"istio-ingress/ingressgateway"` |  |
| keycloakx.istio.auth.url | string | `""` |  |
| keycloakx.metrics.enabled | bool | `false` |  |
| keycloakx.podDisruptionBudget | object | `{}` |  |
| keycloakx.proxy.mode | string | `"xforwarded"` |  |
| keycloakx.resources.limits.memory | string | `"1024Mi"` |  |
| keycloakx.resources.requests.cpu | string | `"100m"` |  |
| keycloakx.resources.requests.memory | string | `"640Mi"` |  |
| keycloakx.service.httpPort | int | `8080` |  |
| keycloakx.serviceMonitor.enabled | bool | `false` |  |
| keycloakx.serviceMonitor.interval | string | `"30s"` |  |
