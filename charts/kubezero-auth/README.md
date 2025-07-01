# kubezero-auth

![Version: 0.6.4](https://img.shields.io/badge/Version-0.6.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 26.0.5](https://img.shields.io/badge/AppVersion-26.0.5-informational?style=flat-square)

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
| oci://registry-1.docker.io/bitnamicharts | keycloak | 24.7.4 |

# Keycloak
   
## Operator

https://www.keycloak.org/operator/installation
https://github.com/keycloak/keycloak/tree/main/operator
https://github.com/aerogear/keycloak-metrics-spi
https://github.com/keycloak/keycloak-benchmark/tree/main/provision/minikube/keycloak/templates

## Resources
- https://github.com/bitnami/charts/tree/main/bitnami/keycloak
   
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| keycloak.auth.adminUser | string | `"admin"` |  |
| keycloak.auth.existingSecret | string | `"keycloak-auth"` |  |
| keycloak.auth.passwordSecretKey | string | `"admin-password"` |  |
| keycloak.enabled | bool | `false` |  |
| keycloak.externalDatabase.database | string | `"keycloak"` |  |
| keycloak.externalDatabase.existingSecret | string | `"keycloak-pg"` |  |
| keycloak.externalDatabase.existingSecretPasswordKey | string | `"password"` |  |
| keycloak.externalDatabase.host | string | `"keycloak-pg-rw"` |  |
| keycloak.externalDatabase.port | int | `5432` |  |
| keycloak.externalDatabase.user | string | `"keycloak"` |  |
| keycloak.hostnameStrict | bool | `false` |  |
| keycloak.istio.admin.enabled | bool | `false` |  |
| keycloak.istio.admin.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| keycloak.istio.admin.url | string | `""` |  |
| keycloak.istio.auth.enabled | bool | `false` |  |
| keycloak.istio.auth.gateway | string | `"istio-ingress/ingressgateway"` |  |
| keycloak.istio.auth.url | string | `""` |  |
| keycloak.metrics.enabled | bool | `false` |  |
| keycloak.metrics.serviceMonitor.enabled | bool | `true` |  |
| keycloak.pdb.create | bool | `false` |  |
| keycloak.pdb.minAvailable | int | `1` |  |
| keycloak.postgresql.enabled | bool | `false` |  |
| keycloak.production | bool | `true` |  |
| keycloak.proxyHeaders | string | `"xforwarded"` |  |
| keycloak.replicaCount | int | `1` |  |
| keycloak.resources.limits.memory | string | `"1024Mi"` |  |
| keycloak.resources.requests.cpu | string | `"100m"` |  |
| keycloak.resources.requests.memory | string | `"640Mi"` |  |
