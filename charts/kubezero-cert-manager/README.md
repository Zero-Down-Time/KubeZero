# kubezero-cert-manager

![Version: 0.9.11](https://img.shields.io/badge/Version-0.9.11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for cert-manager

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.26.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | >= 0.1.6 |
| https://charts.jetstack.io | cert-manager | v1.17.0 |

## AWS - OIDC IAM roles

## Resolver Secrets
If your resolvers need additional sercrets like CloudFlare API tokens etc. make sure to provide these secrets separatly matching your defined issuers.

## Resources
- [Backup & Restore](https://cert-manager.io/docs/tutorials/backup/)
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert-manager.cainjector.extraArgs[0] | string | `"--logging-format=json"` |  |
| cert-manager.cainjector.extraArgs[1] | string | `"--leader-elect=false"` |  |
| cert-manager.crds.enabled | bool | `true` |  |
| cert-manager.enableCertificateOwnerRef | bool | `true` |  |
| cert-manager.enabled | bool | `true` |  |
| cert-manager.extraArgs[0] | string | `"--logging-format=json"` |  |
| cert-manager.extraArgs[1] | string | `"--leader-elect=false"` |  |
| cert-manager.extraArgs[2] | string | `"--dns01-recursive-nameservers-only"` |  |
| cert-manager.global.leaderElection.namespace | string | `"cert-manager"` |  |
| cert-manager.ingressShim.defaultIssuerKind | string | `"ClusterIssuer"` |  |
| cert-manager.ingressShim.defaultIssuerName | string | `"letsencrypt-dns-prod"` |  |
| cert-manager.prometheus.servicemonitor.enabled | bool | `false` |  |
| cert-manager.startupapicheck.enabled | bool | `false` |  |
| cert-manager.webhook.extraArgs[0] | string | `"--logging-format=json"` |  |
| clusterIssuer | object | `{}` |  |
| localCA.enabled | bool | `false` |  |
| localCA.selfsigning | bool | `true` |  |
