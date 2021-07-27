# kubezero-aws-efs-csi-driver

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![AppVersion: 1.3.1](https://img.shields.io/badge/AppVersion-1.3.1-informational?style=flat-square)

KubeZero Umbrella Chart for aws-efs-csi-driver

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Quarky9 |  |  |

## Source Code

* <https://github.com/Zero-Down-Time/kubezero>
* <https://github.com/kubernetes-sigs/aws-efs-csi-driver>

## Requirements

Kubernetes: `>=1.18.0-0`

| Repository | Name | Version |
|------------|------|---------|
|  | aws-efs-csi-driver | 2.1.1 |
| https://zero-down-time.github.io/kubezero/ | kubezero-lib | >= 0.1.3 |

## Storage Class
Optionally creates the *efs-cs* storage class.
Could also be made the default storage class if requested.

## Multiple PVs & PVCs backed by same EFS file system
Details also see: [Reserve PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reserving-a-persistentvolume)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws-efs-csi-driver.controller.create | bool | `true` |  |
| aws-efs-csi-driver.controller.logLevel | int | `1` |  |
| aws-efs-csi-driver.controller.nodeSelector."node-role.kubernetes.io/master" | string | `""` |  |
| aws-efs-csi-driver.controller.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-efs-csi-driver.controller.tolerations[0].key | string | `"node-role.kubernetes.io/master"` |  |
| aws-efs-csi-driver.node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"node.kubernetes.io/csi.efs.fs"` |  |
| aws-efs-csi-driver.node.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"Exists"` |  |
| aws-efs-csi-driver.node.logLevel | int | `1` |  |
| aws-efs-csi-driver.node.resources.limits.memory | string | `"128Mi"` |  |
| aws-efs-csi-driver.node.resources.requests.cpu | string | `"20m"` |  |
| aws-efs-csi-driver.node.resources.requests.memory | string | `"64Mi"` |  |
| aws-efs-csi-driver.replicaCount | int | `1` |  |
| aws-efs-csi-driver.storageClasses[0].name | string | `"efs-sc"` |  |
