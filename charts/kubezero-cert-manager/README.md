# kubezero-cert-manager

![Version: 0.6.1](https://img.shields.io/badge/Version-0.6.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Umbrella Chart for cert-manager

**Homepage:** <https://kubezero.com>

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager | 1.4.0 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## AWS - IAM Role
If you use kiam or kube2iam and restrict access on nodes running cert-manager please adjust:
```
cert-manager.podAnnotations:
  iam.amazonaws.com/role: <ROLE>
```

## Resolver Secrets
If your resolvers need additional sercrets like CloudFlare API tokens etc. make sure to provide these secrets separatly matching your defined issuers.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert-manager.cainjector.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| cert-manager.cainjector.tolerations[0].effect | string | `"NoSchedule"` |  |
| cert-manager.cainjector.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| cert-manager.enabled | bool | `true` |  |
| cert-manager.extraArgs[0] | string | `"--dns01-recursive-nameservers-only"` |  |
| cert-manager.global.leaderElection.namespace | string | `"cert-manager"` |  |
| cert-manager.ingressShim.defaultIssuerKind | string | `"ClusterIssuer"` |  |
| cert-manager.ingressShim.defaultIssuerName | string | `"letsencrypt-dns-prod"` |  |
| cert-manager.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| cert-manager.prometheus.servicemonitor.enabled | bool | `false` |  |
| cert-manager.tolerations[0].effect | string | `"NoSchedule"` |  |
| cert-manager.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| cert-manager.webhook.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| cert-manager.webhook.tolerations[0].effect | string | `"NoSchedule"` |  |
| cert-manager.webhook.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| clusterIssuer | object | `{}` |  |
| localCA.enabled | bool | `false` |  |
| localCA.selfsigning | bool | `true` |  |
