# kubezero

![Version: 1.32.6](https://img.shields.io/badge/Version-1.32.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero - Root App of Apps chart

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.32.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts | kubezero-lib | 0.2.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| addons.aws-eks-asg-rolling-update-handler.enabled | bool | `false` |  |
| addons.aws-node-termination-handler.enabled | bool | `false` |  |
| addons.cluster-autoscaler.enabled | bool | `false` |  |
| addons.clusterBackup.enabled | bool | `false` |  |
| addons.enabled | bool | `false` |  |
| addons.external-dns.enabled | bool | `false` |  |
| addons.forseti.enabled | bool | `false` |  |
| addons.sealed-secrets.enabled | bool | `false` |  |
| addons.targetRevision | string | `"0.8.14"` |  |
| argo.argo-cd.enabled | bool | `false` |  |
| argo.argo-cd.istio.enabled | bool | `false` |  |
| argo.argocd-image-updater.enabled | bool | `false` |  |
| argo.enabled | bool | `false` |  |
| argo.namespace | string | `"argocd"` |  |
| argo.targetRevision | string | `"0.4.2"` |  |
| cert-manager.enabled | bool | `false` |  |
| cert-manager.namespace | string | `"cert-manager"` |  |
| cert-manager.targetRevision | string | `"0.9.12"` |  |
| falco.enabled | bool | `false` |  |
| falco.k8saudit.enabled | bool | `false` |  |
| falco.targetRevision | string | `"0.1.2"` |  |
| global.apiServerUrl | string | `"localhost:6443"` |  |
| global.aws.accountId | string | `"123456789012"` |  |
| global.aws.region | string | `"the-moon"` |  |
| global.clusterName | string | `"zdt-trial-cluster"` |  |
| global.gcp | object | `{}` |  |
| global.highAvailable | bool | `false` |  |
| global.platform | string | `"aws"` |  |
| istio-ingress.chart | string | `"kubezero-istio-gateway"` |  |
| istio-ingress.enabled | bool | `false` |  |
| istio-ingress.gateway.service | object | `{}` |  |
| istio-ingress.namespace | string | `"istio-ingress"` |  |
| istio-ingress.targetRevision | string | `"0.26.1"` |  |
| istio-private-ingress.chart | string | `"kubezero-istio-gateway"` |  |
| istio-private-ingress.enabled | bool | `false` |  |
| istio-private-ingress.gateway.service | object | `{}` |  |
| istio-private-ingress.namespace | string | `"istio-ingress"` |  |
| istio-private-ingress.targetRevision | string | `"0.26.1"` |  |
| istio.enabled | bool | `false` |  |
| istio.namespace | string | `"istio-system"` |  |
| istio.targetRevision | string | `"0.26.1"` |  |
| logging.enabled | bool | `false` |  |
| logging.namespace | string | `"logging"` |  |
| logging.targetRevision | string | `"0.8.14"` |  |
| metrics.enabled | bool | `false` |  |
| metrics.istio.grafana | object | `{}` |  |
| metrics.istio.prometheus | object | `{}` |  |
| metrics.kubezero.prometheus.prometheusSpec.additionalScrapeConfigs | list | `[]` |  |
| metrics.namespace | string | `"monitoring"` |  |
| metrics.targetRevision | string | `"0.12.0"` |  |
| network.cilium.enabled | bool | `true` |  |
| network.enabled | bool | `false` |  |
| network.retain | bool | `true` |  |
| network.targetRevision | string | `"0.5.9"` |  |
| operators.enabled | bool | `false` |  |
| operators.namespace | string | `"operators"` |  |
| operators.targetRevision | string | `"0.2.1"` |  |
| policy.enabled | bool | `false` |  |
| policy.namespace | string | `"kyverno"` |  |
| policy.targetRevision | string | `"0.1.0"` |  |
| storage.aws-ebs-csi-driver.enabled | bool | `false` |  |
| storage.aws-efs-csi-driver.enabled | bool | `false` |  |
| storage.enabled | bool | `false` |  |
| storage.gemini.enabled | bool | `false` |  |
| storage.k8up.enabled | bool | `false` |  |
| storage.lvm-localpv.enabled | bool | `false` |  |
| storage.snapshotController.enabled | bool | `false` |  |
| storage.targetRevision | string | `"0.8.11"` |  |
| telemetry.enabled | bool | `false` |  |
| telemetry.namespace | string | `"telemetry"` |  |
| telemetry.targetRevision | string | `"0.5.0"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
