# kubezero-argocd

![Version: 0.8.0](https://img.shields.io/badge/Version-0.8.0-informational?style=flat-square)

KubeZero ArgoCD Helm chart to install ArgoCD itself and the KubeZero ArgoCD Application

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Requirements

Kubernetes: `>= 1.18.0`

| Repository | Name | Version |
|------------|------|---------|
| https://argoproj.github.io/argo-helm | argo-cd | 3.6.10 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-cd.controller.args.appResyncPeriod | string | `"300"` |  |
| argo-cd.controller.args.operationProcessors | string | `"4"` |  |
| argo-cd.controller.args.statusProcessors | string | `"8"` |  |
| argo-cd.controller.logFormat | string | `"json"` |  |
| argo-cd.controller.metrics.enabled | bool | `false` |  |
| argo-cd.controller.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.controller.resources.requests.cpu | string | `"100m"` |  |
| argo-cd.controller.resources.requests.memory | string | `"256Mi"` |  |
| argo-cd.dex.enabled | bool | `false` |  |
| argo-cd.global.image.tag | string | `"v2.0.4"` |  |
| argo-cd.installCRDs | bool | `false` |  |
| argo-cd.repoServer.logFormat | string | `"json"` |  |
| argo-cd.repoServer.metrics.enabled | bool | `false` |  |
| argo-cd.repoServer.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.server.config."resource.customizations" | string | `"cert-manager.io/Certificate:\n  # Lua script for customizing the health status assessment\n  health.lua: |\n    hs = {}\n    if obj.status ~= nil then\n      if obj.status.conditions ~= nil then\n        for i, condition in ipairs(obj.status.conditions) do\n          if condition.type == \"Ready\" and condition.status == \"False\" then\n            hs.status = \"Degraded\"\n            hs.message = condition.message\n            return hs\n          end\n          if condition.type == \"Ready\" and condition.status == \"True\" then\n            hs.status = \"Healthy\"\n            hs.message = condition.message\n            return hs\n          end\n        end\n      end\n    end\n    hs.status = \"Progressing\"\n    hs.message = \"Waiting for certificate\"\n    return hs\n"` |  |
| argo-cd.server.config."ui.bannercontent" | string | `"KubeZero Release 2.20 incl. ArgoCD 2.0 -> Release notes"` |  |
| argo-cd.server.config."ui.bannerurl" | string | `"https://blog.argoproj.io/argo-cd-v2-0-rc1-is-here-f7d21ff1aa64"` |  |
| argo-cd.server.config.url | string | `"argocd.example.com"` | ArgoCD hostname to be exposed via Istio |
| argo-cd.server.extraArgs[0] | string | `"--insecure"` |  |
| argo-cd.server.logFormat | string | `"json"` |  |
| argo-cd.server.metrics.enabled | bool | `false` |  |
| argo-cd.server.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.server.service.servicePortHttpsName | string | `"grpc"` |  |
| istio.enabled | bool | `false` | Deploy Istio VirtualService to expose ArgoCD |
| istio.gateway | string | `"istio-ingress/ingressgateway"` | Name of the Istio gateway to add the VirtualService to |
| istio.ipBlocks | list | `[]` |  |
| kubezero.enabled | bool | `false` |  |
| kubezero.path | string | `"charts/kubezero"` | path within repoURL |
| kubezero.repoURL | string | `"https://github.com/zero-down-time/kubezero"` | repository for kubezero argo applications |
| kubezero.server | string | `"https://kubernetes.default.svc"` | destination cluster |
| kubezero.targetRevision | string | `"HEAD"` | git branch to track |
| kubezero.valuesFiles[0] | string | `"values.yaml"` |  |

## Resources
- https://argoproj.github.io/argo-cd/operator-manual/metrics/
- https://raw.githubusercontent.com/argoproj/argo-cd/master/examples/dashboard.json
