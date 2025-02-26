# kubezero-addons

![Version: 0.8.13](https://img.shields.io/badge/Version-0.8.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.30](https://img.shields.io/badge/AppVersion-v1.30-informational?style=flat-square)

KubeZero umbrella chart for various optional cluster addons

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://bitnami-labs.github.io/sealed-secrets | sealed-secrets | 2.17.1 |
| https://caas-team.github.io/helm-charts/ | py-kube-downscaler | 0.2.12 |
| https://kubernetes-sigs.github.io/external-dns/ | external-dns | 1.15.1 |
| https://kubernetes.github.io/autoscaler | cluster-autoscaler | 9.46.0 |
| https://nvidia.github.io/k8s-device-plugin | nvidia-device-plugin | 0.17.0 |
| https://twin.github.io/helm-charts | aws-eks-asg-rolling-update-handler | 1.5.0 |
| oci://public.ecr.aws/aws-ec2/helm | aws-node-termination-handler | 0.26.0 |
| oci://public.ecr.aws/neuron | neuron-helm-chart | 1.1.1 |

# MetalLB   
   
# device-plugins   
   
## AWS Neuron
Device plugin for [AWS Neuron](https://aws.amazon.com/machine-learning/neuron/) - [Inf1 instances](https://aws.amazon.com/ec2/instance-types/inf1/)
   
## Nvidia

## Cluster AutoScaler
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws-eks-asg-rolling-update-handler.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| aws-eks-asg-rolling-update-handler.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| aws-eks-asg-rolling-update-handler.enabled | bool | `false` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[0].name | string | `"CLUSTER_NAME"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[0].value | string | `""` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[1].name | string | `"AWS_REGION"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[1].value | string | `"us-west-2"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[2].name | string | `"EXECUTION_INTERVAL"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[2].value | string | `"60"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[3].name | string | `"METRICS"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[3].value | string | `"true"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[4].name | string | `"EAGER_CORDONING"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[4].value | string | `"true"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[5].name | string | `"SLOW_MODE"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[5].value | string | `"true"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[6].name | string | `"AWS_ROLE_ARN"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[6].value | string | `""` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[7].name | string | `"AWS_WEB_IDENTITY_TOKEN_FILE"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[7].value | string | `"/var/run/secrets/sts.amazonaws.com/serviceaccount/token"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[8].name | string | `"AWS_STS_REGIONAL_ENDPOINTS"` |  |
| aws-eks-asg-rolling-update-handler.environmentVars[8].value | string | `"regional"` |  |
| aws-eks-asg-rolling-update-handler.image.repository | string | `"twinproduction/aws-eks-asg-rolling-update-handler"` |  |
| aws-eks-asg-rolling-update-handler.image.tag | string | `"v1.8.4"` |  |
| aws-eks-asg-rolling-update-handler.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| aws-eks-asg-rolling-update-handler.resources.limits.memory | string | `"128Mi"` |  |
| aws-eks-asg-rolling-update-handler.resources.requests.cpu | string | `"10m"` |  |
| aws-eks-asg-rolling-update-handler.resources.requests.memory | string | `"32Mi"` |  |
| aws-eks-asg-rolling-update-handler.securityContext.runAsNonRoot | bool | `true` |  |
| aws-eks-asg-rolling-update-handler.securityContext.runAsUser | int | `1001` |  |
| aws-eks-asg-rolling-update-handler.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| aws-eks-asg-rolling-update-handler.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-eks-asg-rolling-update-handler.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| aws-node-termination-handler.deleteLocalData | bool | `true` |  |
| aws-node-termination-handler.emitKubernetesEvents | bool | `true` |  |
| aws-node-termination-handler.enableProbesServer | bool | `true` |  |
| aws-node-termination-handler.enablePrometheusServer | bool | `false` |  |
| aws-node-termination-handler.enableSpotInterruptionDraining | bool | `false` |  |
| aws-node-termination-handler.enableSqsTerminationDraining | bool | `true` |  |
| aws-node-termination-handler.enabled | bool | `false` |  |
| aws-node-termination-handler.extraEnv[0] | object | `{"name":"AWS_ROLE_ARN","value":""}` | "arn:aws:iam::${AWS::AccountId}:role/${AWS::Region}.${ClusterName}.awsNth" |
| aws-node-termination-handler.extraEnv[1].name | string | `"AWS_WEB_IDENTITY_TOKEN_FILE"` |  |
| aws-node-termination-handler.extraEnv[1].value | string | `"/var/run/secrets/sts.amazonaws.com/serviceaccount/token"` |  |
| aws-node-termination-handler.extraEnv[2].name | string | `"AWS_STS_REGIONAL_ENDPOINTS"` |  |
| aws-node-termination-handler.extraEnv[2].value | string | `"regional"` |  |
| aws-node-termination-handler.fullnameOverride | string | `"aws-node-termination-handler"` |  |
| aws-node-termination-handler.ignoreDaemonSets | bool | `true` |  |
| aws-node-termination-handler.jsonLogging | bool | `true` |  |
| aws-node-termination-handler.logFormatVersion | int | `2` |  |
| aws-node-termination-handler.managedTag | string | `"zdt:kubezero:nth:${ClusterName}"` | "zdt:kubezero:nth:${ClusterName}" |
| aws-node-termination-handler.metadataTries | int | `0` |  |
| aws-node-termination-handler.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| aws-node-termination-handler.queueURL | string | `""` | https://sqs.${AWS::Region}.amazonaws.com/${AWS::AccountId}/${ClusterName}_Nth |
| aws-node-termination-handler.serviceMonitor.create | bool | `false` |  |
| aws-node-termination-handler.taintNode | bool | `true` |  |
| aws-node-termination-handler.tolerations[0].effect | string | `"NoSchedule"` |  |
| aws-node-termination-handler.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| aws-node-termination-handler.useProviderId | bool | `true` |  |
| cluster-autoscaler.autoDiscovery.clusterName | string | `""` |  |
| cluster-autoscaler.awsRegion | string | `"us-west-2"` |  |
| cluster-autoscaler.enabled | bool | `false` |  |
| cluster-autoscaler.extraArgs.balance-similar-node-groups | bool | `true` |  |
| cluster-autoscaler.extraArgs.ignore-daemonsets-utilization | bool | `true` |  |
| cluster-autoscaler.extraArgs.ignore-taint | string | `"node.cilium.io/agent-not-ready"` |  |
| cluster-autoscaler.extraArgs.scan-interval | string | `"30s"` |  |
| cluster-autoscaler.extraArgs.skip-nodes-with-local-storage | bool | `false` |  |
| cluster-autoscaler.image.repository | string | `"registry.k8s.io/autoscaling/cluster-autoscaler"` |  |
| cluster-autoscaler.image.tag | string | `"v1.31.1"` |  |
| cluster-autoscaler.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| cluster-autoscaler.podDisruptionBudget | bool | `false` |  |
| cluster-autoscaler.prometheusRule.enabled | bool | `false` |  |
| cluster-autoscaler.prometheusRule.interval | string | `"30"` |  |
| cluster-autoscaler.serviceMonitor.enabled | bool | `false` |  |
| cluster-autoscaler.serviceMonitor.interval | string | `"30s"` |  |
| cluster-autoscaler.tolerations[0].effect | string | `"NoSchedule"` |  |
| cluster-autoscaler.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| clusterBackup.enabled | bool | `false` |  |
| clusterBackup.extraEnv | list | `[]` |  |
| clusterBackup.image.name | string | `"public.ecr.aws/zero-downtime/kubezero-admin"` |  |
| clusterBackup.password | string | `""` | /etc/cloudbender/clusterBackup.passphrase |
| clusterBackup.repository | string | `""` | s3:https://s3.amazonaws.com/${CFN[ConfigBucket]}/k8s/${CLUSTERNAME}/clusterBackup |
| external-dns.enabled | bool | `false` |  |
| external-dns.interval | string | `"3m"` |  |
| external-dns.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| external-dns.provider | string | `"inmemory"` |  |
| external-dns.sources[0] | string | `"service"` |  |
| external-dns.tolerations[0].effect | string | `"NoSchedule"` |  |
| external-dns.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| external-dns.triggerLoopOnEvent | bool | `true` |  |
| forseti.aws.iamRoleArn | string | `""` | "arn:aws:iam::${AWS::AccountId}:role/${AWS::Region}.${ClusterName}.kubezeroForseti" |
| forseti.aws.region | string | `""` |  |
| forseti.enabled | bool | `false` |  |
| forseti.image.name | string | `"public.ecr.aws/zero-downtime/forseti"` |  |
| forseti.image.tag | string | `"v0.1.2"` |  |
| fuseDevicePlugin.enabled | bool | `false` |  |
| fuseDevicePlugin.image.name | string | `"public.ecr.aws/zero-downtime/fuse-device-plugin"` |  |
| fuseDevicePlugin.image.tag | string | `"v1.2.0"` |  |
| neuron-helm-chart.devicePlugin.tolerations[0].key | string | `"CriticalAddonsOnly"` |  |
| neuron-helm-chart.devicePlugin.tolerations[0].operator | string | `"Exists"` |  |
| neuron-helm-chart.devicePlugin.tolerations[1].effect | string | `"NoSchedule"` |  |
| neuron-helm-chart.devicePlugin.tolerations[1].key | string | `"aws.amazon.com/neuron"` |  |
| neuron-helm-chart.devicePlugin.tolerations[1].operator | string | `"Exists"` |  |
| neuron-helm-chart.devicePlugin.tolerations[2].effect | string | `"NoSchedule"` |  |
| neuron-helm-chart.devicePlugin.tolerations[2].key | string | `"kubezero-workergroup"` |  |
| neuron-helm-chart.devicePlugin.tolerations[2].operator | string | `"Exists"` |  |
| neuron-helm-chart.devicePlugin.volumeMounts[0].mountPath | string | `"/var/lib/kubelet/device-plugins"` |  |
| neuron-helm-chart.devicePlugin.volumeMounts[0].name | string | `"device-plugin"` |  |
| neuron-helm-chart.devicePlugin.volumeMounts[1].mountPath | string | `"/run"` |  |
| neuron-helm-chart.devicePlugin.volumeMounts[1].name | string | `"infa-map"` |  |
| neuron-helm-chart.devicePlugin.volumes[0].hostPath.path | string | `"/var/lib/kubelet/device-plugins"` |  |
| neuron-helm-chart.devicePlugin.volumes[0].name | string | `"device-plugin"` |  |
| neuron-helm-chart.devicePlugin.volumes[1].hostPath.path | string | `"/run"` |  |
| neuron-helm-chart.devicePlugin.volumes[1].name | string | `"infa-map"` |  |
| neuron-helm-chart.enabled | bool | `false` |  |
| neuron-helm-chart.npd.enabled | bool | `false` |  |
| nvidia-device-plugin.cdi.nvidiaHookPath | string | `"/usr/bin"` |  |
| nvidia-device-plugin.config.default | string | `"default"` |  |
| nvidia-device-plugin.config.map.default | string | `"version: v1\nflags:\n  migStrategy: none"` |  |
| nvidia-device-plugin.config.map.time-slice-4x | string | `"version: v1\nflags:\n  migStrategy: none\nsharing:\n  timeSlicing:\n    resources:\n    - name: nvidia.com/gpu\n      replicas: 4"` |  |
| nvidia-device-plugin.deviceDiscoveryStrategy | string | `"nvml"` |  |
| nvidia-device-plugin.enabled | bool | `false` |  |
| nvidia-device-plugin.runtimeClassName | string | `"nvidia"` |  |
| nvidia-device-plugin.tolerations[0].effect | string | `"NoSchedule"` |  |
| nvidia-device-plugin.tolerations[0].key | string | `"nvidia.com/gpu"` |  |
| nvidia-device-plugin.tolerations[0].operator | string | `"Exists"` |  |
| nvidia-device-plugin.tolerations[1].effect | string | `"NoSchedule"` |  |
| nvidia-device-plugin.tolerations[1].key | string | `"kubezero-workergroup"` |  |
| nvidia-device-plugin.tolerations[1].operator | string | `"Exists"` |  |
| py-kube-downscaler.enabled | bool | `false` |  |
| py-kube-downscaler.excludedNamespaces[0] | string | `"kube-system"` |  |
| py-kube-downscaler.excludedNamespaces[1] | string | `"operators"` |  |
| py-kube-downscaler.excludedNamespaces[2] | string | `"monitoring"` |  |
| py-kube-downscaler.excludedNamespaces[3] | string | `"logging"` |  |
| py-kube-downscaler.excludedNamespaces[4] | string | `"telemetry"` |  |
| py-kube-downscaler.excludedNamespaces[5] | string | `"istio-system"` |  |
| py-kube-downscaler.excludedNamespaces[6] | string | `"istio-ingress"` |  |
| py-kube-downscaler.excludedNamespaces[7] | string | `"cert-manager"` |  |
| py-kube-downscaler.excludedNamespaces[8] | string | `"argocd"` |  |
| py-kube-downscaler.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| py-kube-downscaler.resources.limits.cpu | string | `nil` |  |
| py-kube-downscaler.resources.limits.memory | string | `"256Mi"` |  |
| py-kube-downscaler.resources.requests.cpu | string | `"20m"` |  |
| py-kube-downscaler.resources.requests.memory | string | `"48Mi"` |  |
| py-kube-downscaler.tolerations[0].effect | string | `"NoSchedule"` |  |
| py-kube-downscaler.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| sealed-secrets.enabled | bool | `false` |  |
| sealed-secrets.fullnameOverride | string | `"sealed-secrets-controller"` |  |
| sealed-secrets.keyrenewperiod | string | `"0"` |  |
| sealed-secrets.metrics.serviceMonitor.enabled | bool | `false` |  |
| sealed-secrets.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| sealed-secrets.resources.limits.memory | string | `"128Mi"` |  |
| sealed-secrets.resources.requests.cpu | string | `"10m"` |  |
| sealed-secrets.resources.requests.memory | string | `"24Mi"` |  |
| sealed-secrets.tolerations[0].effect | string | `"NoSchedule"` |  |
| sealed-secrets.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
