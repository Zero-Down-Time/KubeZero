# kubezero-network

![Version: 0.5.8](https://img.shields.io/badge/Version-0.5.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for all things network

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://haproxytech.github.io/helm-charts | haproxy | 1.24.0 |
| https://helm.cilium.io/ | cilium | 1.17.3 |
| https://metallb.github.io/metallb | metallb | 0.14.9 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cilium.cgroup.autoMount.enabled | bool | `false` |  |
| cilium.cgroup.hostRoot | string | `"/sys/fs/cgroup"` |  |
| cilium.cluster.id | int | `240` |  |
| cilium.cluster.name | string | `"default"` |  |
| cilium.cni.binPath | string | `"/usr/libexec/cni"` |  |
| cilium.cni.exclusive | bool | `false` |  |
| cilium.cni.logFile | string | `"/var/log/cilium-cni.log"` |  |
| cilium.enabled | bool | `false` |  |
| cilium.envoy.enabled | bool | `false` |  |
| cilium.hubble.enabled | bool | `false` |  |
| cilium.hubble.relay.enabled | bool | `false` |  |
| cilium.hubble.tls.auto.certManagerIssuerRef.group | string | `"cert-manager.io"` |  |
| cilium.hubble.tls.auto.certManagerIssuerRef.kind | string | `"ClusterIssuer"` |  |
| cilium.hubble.tls.auto.certManagerIssuerRef.name | string | `"kubezero-local-ca-issuer"` |  |
| cilium.hubble.tls.auto.method | string | `"cert-manager"` |  |
| cilium.hubble.ui.enabled | bool | `false` |  |
| cilium.image.useDigest | bool | `false` |  |
| cilium.ipam.operator.clusterPoolIPv4PodCIDRList[0] | string | `"10.240.0.0/16"` |  |
| cilium.l7Proxy | bool | `false` |  |
| cilium.operator.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| cilium.operator.prometheus.enabled | bool | `false` |  |
| cilium.operator.prometheus.serviceMonitor.enabled | bool | `false` |  |
| cilium.operator.replicas | int | `1` |  |
| cilium.operator.tolerations[0].effect | string | `"NoSchedule"` |  |
| cilium.operator.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| cilium.operator.tolerations[1].effect | string | `"NoSchedule"` |  |
| cilium.operator.tolerations[1].key | string | `"node.cilium.io/agent-not-ready"` |  |
| cilium.prometheus.enabled | bool | `false` |  |
| cilium.prometheus.port | int | `9091` |  |
| cilium.prometheus.serviceMonitor.enabled | bool | `false` |  |
| cilium.resources.limits.memory | string | `"1Gi"` |  |
| cilium.resources.requests.cpu | string | `"10m"` |  |
| cilium.resources.requests.memory | string | `"160Mi"` |  |
| cilium.routingMode | string | `"tunnel"` |  |
| cilium.sysctlfix.enabled | bool | `false` |  |
| cilium.tunnelProtocol | string | `"geneve"` |  |
| haproxy.PodDisruptionBudget.enable | bool | `false` |  |
| haproxy.PodDisruptionBudget.minAvailable | int | `1` |  |
| haproxy.args.defaults[0] | string | `"-f"` |  |
| haproxy.args.defaults[1] | string | `"/usr/local/etc/haproxy/includes/global.cfg"` |  |
| haproxy.args.defaults[2] | string | `"-f"` |  |
| haproxy.args.defaults[3] | string | `"/usr/local/etc/haproxy/includes/prometheus.cfg"` |  |
| haproxy.args.defaults[4] | string | `"-f"` |  |
| haproxy.args.defaults[5] | string | `"/usr/local/etc/haproxy/haproxy.cfg"` |  |
| haproxy.config | string | `"frontend fe_main\n  bind :8080\n  default_backend be_main\n\nbackend be_main\n  server web1 10.0.0.1:8080 check\n"` |  |
| haproxy.containerPorts.http | int | `8080` |  |
| haproxy.containerPorts.https | string | `nil` |  |
| haproxy.containerPorts.prometheus | int | `8404` |  |
| haproxy.containerPorts.stat | string | `nil` |  |
| haproxy.enabled | bool | `false` |  |
| haproxy.includes."global.cfg" | string | `"global\n  log stdout format raw local0\n  maxconn 2048\n\ndefaults\n  log global\n  mode tcp\n  option http-server-close\n  timeout connect 10s\n  timeout client 30s\n  timeout client-fin 30s\n  timeout server 30s\n  timeout tunnel  1h\n\nresolvers coredns\n  accepted_payload_size 4096\n  parse-resolv-conf\n  hold valid    10s\n  hold other    10s\n  hold refused  10s\n  hold nx       10s\n  hold timeout  10s\n"` |  |
| haproxy.includes."prometheus.cfg" | string | `"frontend prometheus\n  bind *:8404\n  mode http\n  http-request use-service prometheus-exporter if { path /metrics }\n  no log\n  stats enable\n  stats uri /stats\n  stats refresh 10s\n  stats auth admin:letmein\n"` |  |
| haproxy.livenessProbe.failureThreshold | int | `3` |  |
| haproxy.livenessProbe.initialDelaySeconds | int | `0` |  |
| haproxy.livenessProbe.periodSeconds | int | `10` |  |
| haproxy.livenessProbe.successThreshold | int | `1` |  |
| haproxy.livenessProbe.tcpSocket.port | int | `8404` |  |
| haproxy.livenessProbe.timeoutSeconds | int | `1` |  |
| haproxy.readinessProbe.failureThreshold | int | `3` |  |
| haproxy.readinessProbe.initialDelaySeconds | int | `0` |  |
| haproxy.readinessProbe.periodSeconds | int | `10` |  |
| haproxy.readinessProbe.successThreshold | int | `1` |  |
| haproxy.readinessProbe.tcpSocket.port | int | `8404` |  |
| haproxy.readinessProbe.timeoutSeconds | int | `1` |  |
| haproxy.replicaCount | int | `1` |  |
| haproxy.resources.requests.cpu | string | `"10m"` |  |
| haproxy.resources.requests.memory | string | `"48Mi"` |  |
| haproxy.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| haproxy.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| haproxy.securityContext.enabled | bool | `true` |  |
| haproxy.securityContext.runAsGroup | int | `1000` |  |
| haproxy.securityContext.runAsNonRoot | bool | `true` |  |
| haproxy.securityContext.runAsUser | int | `1000` |  |
| haproxy.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| haproxy.serviceMonitor.enabled | bool | `false` |  |
| haproxy.serviceMonitor.endpoints[0].interval | string | `"30s"` |  |
| haproxy.serviceMonitor.endpoints[0].params.no-maint[0] | string | `"empty"` |  |
| haproxy.serviceMonitor.endpoints[0].path | string | `"/metrics"` |  |
| haproxy.serviceMonitor.endpoints[0].port | string | `"prometheus"` |  |
| haproxy.serviceMonitor.endpoints[0].scheme | string | `"http"` |  |
| metallb.controller.nodeSelector."node-role.kubernetes.io/control-plane" | string | `""` |  |
| metallb.controller.tolerations[0].effect | string | `"NoSchedule"` |  |
| metallb.controller.tolerations[0].key | string | `"node-role.kubernetes.io/control-plane"` |  |
| metallb.enabled | bool | `false` |  |
| metallb.ipAddressPools | list | `[]` |  |
| multus.clusterNetwork | string | `"cilium"` |  |
| multus.defaultNetworks | list | `[]` |  |
| multus.enabled | bool | `false` |  |
| multus.image.repository | string | `"ghcr.io/k8snetworkplumbingwg/multus-cni"` |  |
| multus.image.tag | string | `"v4.2.0"` |  |
| multus.readinessindicatorfile | string | `"/etc/cni/net.d/05-cilium.conflist"` |  |
