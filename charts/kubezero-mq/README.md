# kubezero-mq

![Version: 0.3.10](https://img.shields.io/badge/Version-0.3.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for MQ systems like NATS, RabbitMQ

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.26.0`

| Repository | Name | Version |
|------------|------|---------|
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | >= 0.1.6 |
| https://charts.bitnami.com/bitnami | rabbitmq | 14.6.6 |
| https://charts.bitnami.com/bitnami | rabbitmq-cluster-operator | 4.3.19 |
| https://nats-io.github.io/k8s/helm/charts/ | nats | 1.2.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nats.config.jetstream.enabled | bool | `true` |  |
| nats.enabled | bool | `false` |  |
| nats.istio.enabled | bool | `false` |  |
| nats.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| nats.mqtt.enabled | bool | `false` |  |
| nats.natsBox.enabled | bool | `false` |  |
| nats.promExporter.enabled | bool | `false` |  |
| nats.promExporter.podMonitor.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.clusterOperator.metrics.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.clusterOperator.metrics.serviceMonitor.enabled | bool | `true` |  |
| rabbitmq-cluster-operator.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.msgTopologyOperator.metrics.enabled | bool | `false` |  |
| rabbitmq-cluster-operator.msgTopologyOperator.metrics.serviceMonitor.enabled | bool | `true` |  |
| rabbitmq-cluster-operator.rabbitmqImage.tag | string | `"3.11.4-debian-11-r0"` |  |
| rabbitmq-cluster-operator.useCertManager | bool | `true` |  |
| rabbitmq.auth.existingErlangSecret | string | `"rabbitmq"` |  |
| rabbitmq.auth.existingPasswordSecret | string | `"rabbitmq"` |  |
| rabbitmq.auth.tls.enabled | bool | `false` |  |
| rabbitmq.auth.tls.existingSecret | string | `"rabbitmq-server-certificate"` |  |
| rabbitmq.auth.tls.existingSecretFullChain | bool | `true` |  |
| rabbitmq.auth.tls.failIfNoPeerCert | bool | `false` |  |
| rabbitmq.clustering.enabled | bool | `false` |  |
| rabbitmq.clustering.forceBoot | bool | `false` |  |
| rabbitmq.enabled | bool | `false` |  |
| rabbitmq.hosts | list | `[]` | hostnames of rabbitmq services, used for Istio and TLS |
| rabbitmq.istio.amqp | bool | `false` |  |
| rabbitmq.istio.enabled | bool | `false` |  |
| rabbitmq.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| rabbitmq.istio.mqtt | bool | `false` |  |
| rabbitmq.istio.mqtts | bool | `false` |  |
| rabbitmq.metrics.enabled | bool | `false` |  |
| rabbitmq.metrics.serviceMonitor.enabled | bool | `true` |  |
| rabbitmq.pdb.create | bool | `false` |  |
| rabbitmq.persistence.size | string | `"2Gi"` |  |
| rabbitmq.podAntiAffinityPreset | string | `""` |  |
| rabbitmq.replicaCount | int | `1` |  |
| rabbitmq.resources.requests.cpu | string | `"100m"` |  |
| rabbitmq.resources.requests.memory | string | `"512Mi"` |  |
| rabbitmq.topologySpreadConstraints | string | `"- maxSkew: 1\n  topologyKey: topology.kubernetes.io/zone\n  whenUnsatisfiable: DoNotSchedule\n  labelSelector:\n    matchLabels: {{- include \"common.labels.matchLabels\" . | nindent 6 }}\n- maxSkew: 1\n  topologyKey: kubernetes.io/hostname\n  whenUnsatisfiable: DoNotSchedule\n  labelSelector:\n    matchLabels: {{- include \"common.labels.matchLabels\" . | nindent 6 }}"` |  |
| rabbitmq.ulimitNofiles | string | `""` |  |

## Resources

### NATS
- https://grafana.com/grafana/dashboards/13707
