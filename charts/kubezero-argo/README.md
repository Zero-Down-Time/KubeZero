# kubezero-argo

![Version: 0.3.2](https://img.shields.io/badge/Version-0.3.2-informational?style=flat-square)

KubeZero Argo - Events, Workflow, CD

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://argoproj.github.io/argo-helm | argo-cd | 7.8.23 |
| https://argoproj.github.io/argo-helm | argo-events | 2.4.15 |
| https://argoproj.github.io/argo-helm | argocd-image-updater | 0.12.1 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-cd.configs.cm."application.instanceLabelKey" | string | `nil` |  |
| argo-cd.configs.cm."application.resourceTrackingMethod" | string | `"annotation"` |  |
| argo-cd.configs.cm."resource.customizations" | string | `"argoproj.io/Application:\n  health.lua: |\n    hs = {}\n    hs.status = \"Progressing\"\n    hs.message = \"\"\n    if obj.status ~= nil then\n      if obj.status.health ~= nil then\n        hs.status = obj.status.health.status\n        if obj.status.health.message ~= nil then\n          hs.message = obj.status.health.message\n        end\n      end\n    end\n    return hs\n"` |  |
| argo-cd.configs.cm."timeout.reconciliation" | string | `"300s"` |  |
| argo-cd.configs.cm."ui.bannercontent" | string | `"KubeZero v1.31 - Release notes"` |  |
| argo-cd.configs.cm."ui.bannerpermanent" | string | `"true"` |  |
| argo-cd.configs.cm."ui.bannerposition" | string | `"bottom"` |  |
| argo-cd.configs.cm."ui.bannerurl" | string | `"https://kubezero.com/releases/v1.31"` |  |
| argo-cd.configs.cm.installationID | string | `"KubeZero-ArgoCD"` |  |
| argo-cd.configs.cm.url | string | `"https://argocd.example.com"` |  |
| argo-cd.configs.params."controller.diff.server.side" | string | `"true"` |  |
| argo-cd.configs.params."controller.resource.health.persist" | string | `"false"` |  |
| argo-cd.configs.params."controller.sync.timeout.seconds" | int | `1800` |  |
| argo-cd.configs.params."server.enable.gzip" | bool | `true` |  |
| argo-cd.configs.params."server.insecure" | bool | `true` |  |
| argo-cd.configs.secret.argocdServerAdminPassword | string | `"secretref+k8s://v1/Secret/kubezero/kubezero-secrets/argo-cd.adminPassword"` |  |
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
| argo-cd.global.image.tag | string | `"v2.14.9"` |  |
| argo-cd.global.logging.format | string | `"json"` |  |
| argo-cd.global.networkPolicy.create | bool | `true` |  |
| argo-cd.istio.enabled | bool | `false` |  |
| argo-cd.istio.gateway | string | `"istio-ingress/ingressgateway"` |  |
| argo-cd.istio.ipBlocks | list | `[]` |  |
| argo-cd.kubezero.bootstrap | bool | `false` | deploy the KubeZero Project and GitSync Root App |
| argo-cd.kubezero.path | string | `"/"` |  |
| argo-cd.kubezero.repoUrl | string | `""` |  |
| argo-cd.kubezero.sshPrivateKey | string | `"secretref+k8s://v1/Secret/kubezero/kubezero-secrets/argo-cd.kubezero.sshPrivateKey"` |  |
| argo-cd.kubezero.targetRevision | string | `"HEAD"` |  |
| argo-cd.notifications.enabled | bool | `false` |  |
| argo-cd.redisSecretInit.enabled | bool | `false` |  |
| argo-cd.repoServer.metrics.enabled | bool | `false` |  |
| argo-cd.repoServer.metrics.serviceMonitor.enabled | bool | `true` |  |
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
| argo-events.configs.jetstream.versions[0].metricsExporterImage | string | `"natsio/prometheus-nats-exporter:0.16.0"` |  |
| argo-events.configs.jetstream.versions[0].natsImage | string | `"nats:2.10.11-scratch"` |  |
| argo-events.configs.jetstream.versions[0].startCommand | string | `"/nats-server"` |  |
| argo-events.configs.jetstream.versions[0].version | string | `"2.10.11"` |  |
| argo-events.enabled | bool | `false` |  |
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

