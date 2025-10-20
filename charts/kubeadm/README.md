# kubeadm

![Version: 1.33.5](https://img.shields.io/badge/Version-1.33.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero Kubeadm cluster config

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.33.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api.apiAudiences | string | `"istio-ca"` |  |
| api.awsIamAuth | bool | `false` |  |
| api.endpoint | string | `"kube-api.changeme.org:6443"` |  |
| api.etcdServers | string | `"https://etcd:2379"` |  |
| api.extraArgs | object | `{}` |  |
| api.falco.enabled | bool | `false` |  |
| api.listenPort | int | `6443` |  |
| api.oidcEndpoint | string | `""` | s3://${CFN[ConfigBucket]}/k8s/$CLUSTERNAME |
| api.serviceAccountIssuer | string | `""` | https://s3.${REGION}.amazonaws.com/${CFN[ConfigBucket]}/k8s/$CLUSTERNAME |
| domain | string | `"changeme.org"` |  |
| etcd.nodeName | string | `"etcd"` |  |
| etcd.state | string | `"new"` |  |
| global.clusterName | string | `"pleasechangeme"` |  |
| global.highAvailable | bool | `false` |  |
| listenAddress | string | `"0.0.0.0"` | Needs to be set to primary node IP |
| nodeName | string | `"kubezero-node"` | set to $HOSTNAME |
| protectKernelDefaults | bool | `false` |  |
| systemd | bool | `false` | Set to false for openrc, eg. on Gentoo or Alpine |

## Resources

- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/
- https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta3
- https://pkg.go.dev/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta3
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubelet/config/v1beta1/types.go
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/

- https://github.com/awslabs/amazon-eks-ami

### Etcd
- https://itnext.io/breaking-down-and-fixing-etcd-cluster-d81e35b9260d

