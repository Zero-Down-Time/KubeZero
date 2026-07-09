# kubezero-storage

![Version: 0.9.3](https://img.shields.io/badge/Version-0.9.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for all things storage incl. AWS EBS/EFS, openEBS-lvm, gemini

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
|  | garage | 2.2.0 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://charts.fairwinds.com/stable | gemini | 2.1.3 |
| https://k8up-io.github.io/k8up | k8up | 4.9.0 |
| https://kubernetes-sigs.github.io/aws-ebs-csi-driver | aws-ebs-csi-driver | 2.62.0 |
| https://kubernetes-sigs.github.io/aws-efs-csi-driver | aws-efs-csi-driver | 4.3.0 |
| https://openebs.github.io/lvm-localpv | lvm-localpv | 1.9.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws-ebs-csi-driver.controller.defaultFsType | string | `"xfs"` |  |
| aws-ebs-csi-driver.controller.loggingFormat | string | `"json"` |  |
| aws-ebs-csi-driver.controller.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| aws-ebs-csi-driver.controller.replicaCount | int | `1` |  |
| aws-ebs-csi-driver.controller.resources.limits.memory | string | `"40Mi"` |  |
| aws-ebs-csi-driver.controller.resources.requests.cpu | string | `"10m"` |  |
| aws-ebs-csi-driver.controller.resources.requests.memory | string | `"24Mi"` |  |
| aws-ebs-csi-driver.controller.revisionHistoryLimit | int | `2` |  |
| aws-ebs-csi-driver.controller.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.controller.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| aws-ebs-csi-driver.controller.volumeModificationFeature.enabled | bool | `true` |  |
| aws-ebs-csi-driver.enabled | bool | `false` |  |
| aws-ebs-csi-driver.helmTester.enabled | bool | `false` |  |
| aws-ebs-csi-driver.node.enableMetrics | bool | `false` |  |
| aws-ebs-csi-driver.node.enableWindows | bool | `false` |  |
| aws-ebs-csi-driver.node.loggingFormat | string | `"json"` |  |
| aws-ebs-csi-driver.node.priorityClassName | string | `"system-node-critical"` |  |
| aws-ebs-csi-driver.node.reservedVolumeAttachments | int | `3` |  |
| aws-ebs-csi-driver.node.resources.limits.memory | string | `"32Mi"` |  |
| aws-ebs-csi-driver.node.resources.requests.cpu | string | `"10m"` |  |
| aws-ebs-csi-driver.node.resources.requests.memory | string | `"16Mi"` |  |
| aws-ebs-csi-driver.node.revisionHistoryLimit | int | `3` |  |
| aws-ebs-csi-driver.node.tolerateAllTaints | bool | `false` |  |
| aws-ebs-csi-driver.node.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.node.tolerations[0].key | string | `"kubezero-workergroup"` |  |
| aws-ebs-csi-driver.node.tolerations[0].operator | string | `"Exists"` |  |
| aws-ebs-csi-driver.node.tolerations[1].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.node.tolerations[1].key | string | `"nvidia.com/gpu"` |  |
| aws-ebs-csi-driver.node.tolerations[1].operator | string | `"Exists"` |  |
| aws-ebs-csi-driver.node.tolerations[2].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.node.tolerations[2].key | string | `"aws.amazon.com/neuron"` |  |
| aws-ebs-csi-driver.node.tolerations[2].operator | string | `"Exists"` |  |
| aws-ebs-csi-driver.node.tolerations[3].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.node.tolerations[3].key | string | `"ebs.csi.aws.com/agent-not-ready"` |  |
| aws-ebs-csi-driver.node.tolerations[3].operator | string | `"Exists"` |  |
| aws-ebs-csi-driver.node.tolerations[4].effect | string | `"NoSchedule"` |  |
| aws-ebs-csi-driver.node.tolerations[4].key | string | `"efs.csi.aws.com/agent-not-ready"` |  |
| aws-ebs-csi-driver.node.tolerations[4].operator | string | `"Exists"` |  |
| aws-ebs-csi-driver.storageClasses[0].allowVolumeExpansion | bool | `true` |  |
| aws-ebs-csi-driver.storageClasses[0].name | string | `"ebs-sc-gp2-xfs"` |  |
| aws-ebs-csi-driver.storageClasses[0].parameters."csi.storage.k8s.io/fstype" | string | `"xfs"` |  |
| aws-ebs-csi-driver.storageClasses[0].parameters.encrypted | string | `"true"` |  |
| aws-ebs-csi-driver.storageClasses[0].parameters.type | string | `"gp2"` |  |
| aws-ebs-csi-driver.storageClasses[0].volumeBindingMode | string | `"WaitForFirstConsumer"` |  |
| aws-ebs-csi-driver.storageClasses[1].allowVolumeExpansion | bool | `true` |  |
| aws-ebs-csi-driver.storageClasses[1].annotations."storageclass.kubernetes.io/is-default-class" | string | `"true"` |  |
| aws-ebs-csi-driver.storageClasses[1].name | string | `"ebs-sc-gp3-xfs"` |  |
| aws-ebs-csi-driver.storageClasses[1].parameters."csi.storage.k8s.io/fstype" | string | `"xfs"` |  |
| aws-ebs-csi-driver.storageClasses[1].parameters.encrypted | string | `"true"` |  |
| aws-ebs-csi-driver.storageClasses[1].parameters.type | string | `"gp3"` |  |
| aws-ebs-csi-driver.storageClasses[1].volumeBindingMode | string | `"WaitForFirstConsumer"` |  |
| aws-efs-csi-driver.controller.containerSecurityContext.privileged | bool | `false` |  |
| aws-efs-csi-driver.controller.create | bool | `true` |  |
| aws-efs-csi-driver.controller.logLevel | int | `2` |  |
| aws-efs-csi-driver.controller.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| aws-efs-csi-driver.controller.regionalStsEndpoints | bool | `true` |  |
| aws-efs-csi-driver.controller.replicaCount | int | `1` |  |
| aws-efs-csi-driver.controller.revisionHistoryLimit | int | `2` |  |
| aws-efs-csi-driver.controller.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.controller.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| aws-efs-csi-driver.controller.workerThreads | int | `10` |  |
| aws-efs-csi-driver.enabled | bool | `false` |  |
| aws-efs-csi-driver.node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"node.kubernetes.io/csi.efs.fs"` |  |
| aws-efs-csi-driver.node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.forceUnmountAfterTimeout | bool | `true` |  |
| aws-efs-csi-driver.node.logLevel | int | `2` |  |
| aws-efs-csi-driver.node.maxInflightMountCalls | int | `1` |  |
| aws-efs-csi-driver.node.maxInflightMountCallsOptIn | bool | `true` |  |
| aws-efs-csi-driver.node.resources.limits.cpu | int | `1` |  |
| aws-efs-csi-driver.node.resources.limits.memory | string | `"256Mi"` |  |
| aws-efs-csi-driver.node.resources.requests.cpu | string | `"20m"` |  |
| aws-efs-csi-driver.node.resources.requests.memory | string | `"96Mi"` |  |
| aws-efs-csi-driver.node.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.node.tolerations[0].key | string | `"kubezero-workergroup"` |  |
| aws-efs-csi-driver.node.tolerations[0].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.tolerations[1].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.node.tolerations[1].key | string | `"nvidia.com/gpu"` |  |
| aws-efs-csi-driver.node.tolerations[1].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.tolerations[2].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.node.tolerations[2].key | string | `"aws.amazon.com/neuron"` |  |
| aws-efs-csi-driver.node.tolerations[2].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.tolerations[3].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.node.tolerations[3].key | string | `"ebs.csi.aws.com/agent-not-ready"` |  |
| aws-efs-csi-driver.node.tolerations[3].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.tolerations[4].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.node.tolerations[4].key | string | `"efs.csi.aws.com/agent-not-ready"` |  |
| aws-efs-csi-driver.node.tolerations[4].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.volMetricsOptIn | bool | `false` |  |
| aws-efs-csi-driver.useHelmHooksForCSIDriver | bool | `false` |  |
| garage.deployment.replicaCount | int | `1` |  |
| garage.enabled | bool | `false` |  |
| garage.garage.compressionLevel | string | `"3"` |  |
| garage.garage.dbEngine | string | `"sqlite"` |  |
| garage.garage.existingRpcSecret | string | `"garage-rpc-secret"` |  |
| garage.garage.metadataAutoSnapshotInterval | string | `"6h"` |  |
| garage.garage.replicationFactor | string | `"1"` |  |
| garage.garage.rpcSecret | string | `"secretref+k8s://v1/Secret/kubezero/kubezero-secrets/garage.rpcSecret"` |  |
| garage.garage.s3.api.region | string | `"local-garage"` |  |
| garage.garage.s3.api.rootDomain | string | `".s3.garage.cluster.local"` |  |
| garage.garage.s3.web.index | string | `"index.html"` |  |
| garage.garage.s3.web.rootDomain | string | `".web.garage.cluster.local"` |  |
| garage.persistence.data.size | string | `"16Gi"` |  |
| garage.persistence.enabled | bool | `true` |  |
| garage.persistence.meta.size | string | `"384Mi"` |  |
| gemini.enabled | bool | `false` |  |
| gemini.resources.limits.cpu | string | `"400m"` |  |
| gemini.resources.limits.memory | string | `"128Mi"` |  |
| gemini.resources.requests.cpu | string | `"20m"` |  |
| gemini.resources.requests.memory | string | `"32Mi"` |  |
| k8up.enabled | bool | `false` |  |
| k8up.k8up.enableLeaderElection | bool | `false` |  |
| k8up.metrics.serviceMonitor.enabled | bool | `true` |  |
| k8up.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| k8up.replicaCount | int | `1` |  |
| k8up.resources.limits.memory | string | `"256Mi"` |  |
| k8up.resources.requests.cpu | string | `"20m"` |  |
| k8up.resources.requests.memory | string | `"32Mi"` |  |
| k8up.tolerations[0].effect | string | `"NoSchedule"` |  |
| k8up.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| lvm-localpv.analytics.enabled | bool | `false` |  |
| lvm-localpv.crds.csi.volumeSnapshots.enabled | bool | `false` |  |
| lvm-localpv.enabled | bool | `false` |  |
| lvm-localpv.lvmController.logLevel | int | `2` |  |
| lvm-localpv.lvmController.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| lvm-localpv.lvmController.tolerations[0].effect | string | `"NoSchedule"` |  |
| lvm-localpv.lvmController.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| lvm-localpv.lvmNode.logLevel | int | `2` |  |
| lvm-localpv.lvmNode.nodeSelector."node.kubernetes.io/lvm" | string | `"openebs"` |  |
| lvm-localpv.lvmNode.tolerations[0].effect | string | `"NoSchedule"` |  |
| lvm-localpv.lvmNode.tolerations[0].key | string | `"kubezero-workergroup"` |  |
| lvm-localpv.lvmNode.tolerations[0].operator | string | `"Exists"` |  |
| lvm-localpv.prometheus.enabled | bool | `false` |  |
| lvm-localpv.storageClass.default | bool | `false` |  |
| lvm-localpv.storageClass.vgpattern | string | `""` |  |
| snapshotController.enabled | bool | `false` |  |
| snapshotController.image.name | string | `"registry.k8s.io/sig-storage/snapshot-controller"` |  |
| snapshotController.image.tag | string | `"v7.0.1"` |  |
| snapshotController.logLevel | int | `2` |  |
| snapshotController.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| snapshotController.replicas | int | `1` |  |
| snapshotController.resources.limits.memory | string | `"64Mi"` |  |
| snapshotController.resources.requests.cpu | string | `"10m"` |  |
| snapshotController.resources.requests.memory | string | `"24Mi"` |  |
| snapshotController.tolerations[0].effect | string | `"NoSchedule"` |  |
| snapshotController.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |

# Snapshotter
- https://kubernetes-csi.github.io/docs/snapshot-controller.html#deployment

## Resources
- https://github.com/openebs/monitoring/blob/develop/docs/openebs-mixin-user-guide.md#install-openebs-mixin-in-existing-prometheus-stack
- https://quay.io/organization/fairwinds
