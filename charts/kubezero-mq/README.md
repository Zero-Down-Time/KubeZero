# kubezero-mq

![Version: 0.3.15](https://img.shields.io/badge/Version-0.3.15-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for MQ systems like NATS, RabbitMQ

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.33.0`

| Repository | Name | Version |
|------------|------|---------|
|  | kafka | 0.1.0 |
| https://akhq.io/ | akhq | 0.26.0 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://nats-io.github.io/k8s/helm/charts/ | nats | 2.12.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| akhq.configuration.akhq.connections.local.properties."bootstrap.servers" | string | `"example-kafka-plain-bootstrap:9092"` |  |
| akhq.enabled | bool | `false` |  |
| akhq.istio.enabled | bool | `false` |  |
| akhq.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| akhq.istio.url | string | `"example-akhq.local"` |  |
| akhq.revisionHistoryLimit | int | `2` |  |
| kafka.cluster.name | string | `"example"` |  |
| kafka.cluster.version | string | `"4.1.1"` |  |
| kafka.connect.enabled | bool | `false` |  |
| kafka.connect.replicas | int | `1` |  |
| kafka.enabled | bool | `false` |  |
| kafka.storage.size | string | `"1Gi"` |  |
| nats.config.cluster.routeURLs.useFQDN | bool | `true` |  |
| nats.config.jetstream.enabled | bool | `true` |  |
| nats.enabled | bool | `false` |  |
| nats.istio.enabled | bool | `false` |  |
| nats.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| nats.mqtt.enabled | bool | `false` |  |
| nats.natsBox.enabled | bool | `false` |  |
| nats.podTemplate.topologySpreadConstraints."kubernetes.io/hostname".maxSkew | int | `1` |  |
| nats.podTemplate.topologySpreadConstraints."kubernetes.io/hostname".whenUnsatisfiable | string | `"DoNotSchedule"` |  |
| nats.promExporter.enabled | bool | `false` |  |
| nats.promExporter.podMonitor.enabled | bool | `false` |  |
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

### Kafka
- https://github.com/sauljabin/kaskade

### NATS
- https://grafana.com/grafana/dashboards/13707
