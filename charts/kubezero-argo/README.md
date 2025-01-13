# kubezero-argo

![Version: 0.2.7](https://img.shields.io/badge/Version-0.2.7-informational?style=flat-square)

KubeZero Argo - Events, Workflow, CD

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.26.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://argoproj.github.io/argo-helm | argo-cd | 7.7.7 |
| https://argoproj.github.io/argo-helm | argo-events | 2.4.9 |
| https://argoproj.github.io/argo-helm | argocd-apps | 2.0.2 |
| https://argoproj.github.io/argo-helm | argocd-image-updater | 0.11.2 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | >= 0.1.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-cd.configs.cm."application.resourceTrackingMethod" | string | `"annotation"` |  |
| argo-cd.configs.cm."resource.customizations" | string | `"cert-manager.io/Certificate:\n  # Lua script for customizing the health status assessment\n  health.lua: |\n    hs = {}\n    if obj.status ~= nil then\n      if obj.status.conditions ~= nil then\n        for i, condition in ipairs(obj.status.conditions) do\n          if condition.type == \"Ready\" and condition.status == \"False\" then\n            hs.status = \"Degraded\"\n            hs.message = condition.message\n            return hs\n          end\n          if condition.type == \"Ready\" and condition.status == \"True\" then\n            hs.status = \"Healthy\"\n            hs.message = condition.message\n            return hs\n          end\n        end\n      end\n    end\n    hs.status = \"Progressing\"\n    hs.message = \"Waiting for certificate\"\n    return hs\n"` |  |
| argo-cd.configs.cm."timeout.reconciliation" | string | `"300s"` |  |
| argo-cd.configs.cm."ui.bannercontent" | string | `"KubeZero v1.31 - Release notes"` |  |
| argo-cd.configs.cm."ui.bannerpermanent" | string | `"true"` |  |
| argo-cd.configs.cm."ui.bannerposition" | string | `"bottom"` |  |
| argo-cd.configs.cm."ui.bannerurl" | string | `"https://kubezero.com/releases/v1.31"` |  |
| argo-cd.configs.cm.url | string | `"https://argocd.example.com"` |  |
| argo-cd.configs.params."controller.diff.server.side" | string | `"true"` |  |
| argo-cd.configs.params."controller.operation.processors" | string | `"5"` |  |
| argo-cd.configs.params."controller.status.processors" | string | `"10"` |  |
| argo-cd.configs.params."server.enable.gzip" | bool | `true` |  |
| argo-cd.configs.params."server.insecure" | bool | `true` |  |
| argo-cd.configs.secret.createSecret | bool | `false` |  |
| argo-cd.configs.ssh.extraHosts | string | `"git.zero-downtime.net ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7UgK7Z4dDcuIW1uMOsuwhrqdkJCvYG/ZjHtLM7WaKFxVRnzNnNkQJNncWIGNDUQ1xxrbsoSNRZDtk0NlOjNtx2aApSWl4iWghkpXELvsZtOZ7I9FSC/E6ImLC3KWfK7P0mhZaF6kHPfpu8Y6pjUyLBTpV1AaVwr0I8onyqGazJOVotTFaBFEi/sT0O2FUk7agwZYfj61w3JGOy3c+fmBcK3lXf/QM90tosOpJNuJ7n5Vk5FDDLkl9rO4XR/+mXHFvITiWb8F5C50YAwjYcy36yWSSryUAAHAuqpgotwh65vSG6fZvFhmEwO2BrCkOV5+k8iRfhy/yZODJzZ5V/5cbMbdZrY6lm/p5/S1wv8BEyPekBGdseqQjEO0IQiQHcMrfgTrrQ7ndbZzVZRByZI+wbGFkBCzNSJcNsoiHjs2EblxYyuW0qUvvrBxLnySvaxyPm4BOukSAZAOEaUrajpQlnHdnY1CGcgbwxw0LNv3euKQ3tDJSUlKO0Wd8d85PRv1THW4Ui9Lhsmv+BPA2vJZDOkx/n0oyPFAB0oyd5JNM38eFxLCmPC2OE63gDP+WmzVO61YCVTnvhpQjEOLawEWVFsk0y25R5z5BboDqJaOFnZF6i517O96cn17z3Ls4hxw3+0rlKczYRoyfUHs7KQENa4mY8YlJweNTBgld//RMUQ=="` |  |
| argo-cd.configs.styles | string | `".sidebar__logo img { content: url(https://cdn.zero-downtime.net/assets/kubezero/logo-small-64.png); }\n.sidebar__logo__text-logo { height: 0em; }\n.sidebar { background: linear-gradient(to bottom, #6A4D79, #493558, #2D1B30, #0D0711); }\n"` |  |
| argo-cd.controller.metrics.enabled | bool | `false` |  |
| argo-cd.controller.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.controller.resources.limits.memory | string | `"2048Mi"` |  |
| argo-cd.controller.resources.requests.cpu | string | `"100m"` |  |
| argo-cd.controller.resources.requests.memory | string | `"512Mi"` |  |
| argo-cd.dex.enabled | bool | `false` |  |
| argo-cd.enabled | bool | `false` |  |
| argo-cd.global.image.repository | string | `"public.ecr.aws/zero-downtime/zdt-argocd"` |  |
| argo-cd.global.image.tag | string | `"v2.13.1"` |  |
| argo-cd.global.logging.format | string | `"json"` |  |
| argo-cd.global.networkPolicy.create | bool | `true` |  |
| argo-cd.istio.enabled | bool | `false` |  |
| argo-cd.istio.gateway | string | `"istio-ingress/ingressgateway"` |  |
| argo-cd.istio.ipBlocks | list | `[]` |  |
| argo-cd.notifications.enabled | bool | `false` |  |
| argo-cd.repoServer.clusterRoleRules.enabled | bool | `true` |  |
| argo-cd.repoServer.clusterRoleRules.rules[0].apiGroups[0] | string | `""` |  |
| argo-cd.repoServer.clusterRoleRules.rules[0].resources[0] | string | `"secrets"` |  |
| argo-cd.repoServer.clusterRoleRules.rules[0].verbs[0] | string | `"get"` |  |
| argo-cd.repoServer.clusterRoleRules.rules[0].verbs[1] | string | `"watch"` |  |
| argo-cd.repoServer.clusterRoleRules.rules[0].verbs[2] | string | `"list"` |  |
| argo-cd.repoServer.initContainers[0].command[0] | string | `"/usr/local/bin/sa2kubeconfig.sh"` |  |
| argo-cd.repoServer.initContainers[0].command[1] | string | `"/home/argocd/.kube/config"` |  |
| argo-cd.repoServer.initContainers[0].image | string | `"{{ default .Values.global.image.repository .Values.repoServer.image.repository }}:{{ default (include \"argo-cd.defaultTag\" .) .Values.repoServer.image.tag }}"` |  |
| argo-cd.repoServer.initContainers[0].imagePullPolicy | string | `"{{ default .Values.global.image.imagePullPolicy .Values.repoServer.image.imagePullPolicy }}"` |  |
| argo-cd.repoServer.initContainers[0].name | string | `"create-kubeconfig"` |  |
| argo-cd.repoServer.initContainers[0].securityContext.allowPrivilegeEscalation | bool | `false` |  |
| argo-cd.repoServer.initContainers[0].securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| argo-cd.repoServer.initContainers[0].securityContext.readOnlyRootFilesystem | bool | `true` |  |
| argo-cd.repoServer.initContainers[0].securityContext.runAsNonRoot | bool | `true` |  |
| argo-cd.repoServer.initContainers[0].securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| argo-cd.repoServer.initContainers[0].volumeMounts[0].mountPath | string | `"/home/argocd/.kube"` |  |
| argo-cd.repoServer.initContainers[0].volumeMounts[0].name | string | `"kubeconfigs"` |  |
| argo-cd.repoServer.metrics.enabled | bool | `false` |  |
| argo-cd.repoServer.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.repoServer.volumeMounts[0].mountPath | string | `"/home/argocd/.kube"` |  |
| argo-cd.repoServer.volumeMounts[0].name | string | `"kubeconfigs"` |  |
| argo-cd.repoServer.volumes[0].emptyDir | object | `{}` |  |
| argo-cd.repoServer.volumes[0].name | string | `"kubeconfigs"` |  |
| argo-cd.server.metrics.enabled | bool | `false` |  |
| argo-cd.server.metrics.serviceMonitor.enabled | bool | `true` |  |
| argo-cd.server.service.servicePortHttpsName | string | `"grpc"` |  |
| argo-events.configs.jetstream.settings.maxFileStore | int | `-1` | Maximum size of the file storage (e.g. 20G) |
| argo-events.configs.jetstream.settings.maxMemoryStore | int | `-1` | Maximum size of the memory storage (e.g. 1G) |
| argo-events.configs.jetstream.streamConfig.duplicates | string | `"300s"` | Not documented at the moment |
| argo-events.configs.jetstream.streamConfig.maxAge | string | `"72h"` | Maximum age of existing messages, i.e. “72h”, “4h35m” |
| argo-events.configs.jetstream.streamConfig.maxBytes | string | `"1GB"` |  |
| argo-events.configs.jetstream.streamConfig.maxMsgs | int | `1000000` | Maximum number of messages before expiring oldest message |
| argo-events.configs.jetstream.streamConfig.replicas | int | `1` | Number of replicas, defaults to 3 and requires minimal 3 |
| argo-events.configs.jetstream.versions[0].configReloaderImage | string | `"natsio/nats-server-config-reloader:0.14.1"` |  |
| argo-events.configs.jetstream.versions[0].metricsExporterImage | string | `"natsio/prometheus-nats-exporter:0.14.0"` |  |
| argo-events.configs.jetstream.versions[0].natsImage | string | `"nats:2.10.11-scratch"` |  |
| argo-events.configs.jetstream.versions[0].startCommand | string | `"/nats-server"` |  |
| argo-events.configs.jetstream.versions[0].version | string | `"2.10.11"` |  |
| argo-events.enabled | bool | `false` |  |
| argocd-apps.applications | object | `{}` |  |
| argocd-apps.enabled | bool | `false` |  |
| argocd-apps.projects | object | `{}` |  |
| argocd-image-updater.authScripts.enabled | bool | `true` |  |
| argocd-image-updater.authScripts.scripts."ecr-login.sh" | string | `"#!/bin/sh\naws ecr --region $AWS_REGION get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d\n"` |  |
| argocd-image-updater.authScripts.scripts."ecr-public-login.sh" | string | `"#!/bin/sh\naws ecr-public --region us-east-1 get-authorization-token --output text --query 'authorizationData.authorizationToken' | base64 -d\n"` |  |
| argocd-image-updater.config.argocd.plaintext | bool | `true` |  |
| argocd-image-updater.enabled | bool | `false` |  |
| argocd-image-updater.fullnameOverride | string | `"argocd-image-updater"` |  |
| argocd-image-updater.metrics.enabled | bool | `false` |  |
| argocd-image-updater.metrics.serviceMonitor.enabled | bool | `true` |  |
| argocd-image-updater.sshConfig.config | string | `"Host *\n  PubkeyAcceptedAlgorithms +ssh-rsa\n  HostkeyAlgorithms +ssh-rsa\n"` |  |

## Resources
- https://github.com/argoproj/argoproj/blob/main/docs/end_user_threat_model.pdf
- https://argoproj.github.io/argo-cd/operator-manual/metrics/
- https://raw.githubusercontent.com/argoproj/argo-cd/master/examples/dashboard.json

