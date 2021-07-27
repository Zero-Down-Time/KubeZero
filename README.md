KubeZero - Zero Down Time Kubernetes platform
========================
KubeZero is a Kubernetes distribution providing an integrated container platform so you can focus on your applications.

# Design philosophy

- Cloud provider agnostic, bare-metal/self-hosted
- No vendor lock in, most components are optional and could be exchanged
- Organic Open Source / open and permissive licenses over closed-source solutions
- No premium services / subscriptions required
- Staying and contributing back to upstream projects as much as possible


# Version / Support Matrix

| KubeZero \ Kubernetes Version          | v1.19 | v1.20 | v1.21 | EOL         |
|----------------------------------------|-------|-------|-------|-------------|
| master branch                          | no    | yes   | alpha |             |
| stable branch                          | yes   | no    | no    |             |
| v2.20.0                                | no    | yes   | no    | 30 Aug 2021 |
| v2.19.0                                | yes   | no    | no    | 30 Aug 2021 |

[Upstream release policy](https://kubernetes.io/releases/)

# Architecure
![aws_architecture](docs/aws_architecture.png)


# Components

## Container runtime
- cri-o rather than Docker for improved security and performance

## Control plane
- support for single node control plane for small clusters / test environments to reduce costs
- access to control plane from within the VPC only by default ( VPN access required for Admin tasks )
- controller nodes are used for various platform admin controllers / operators to reduce costs and noise on worker nodes

## GitOps
- full ArgoCD support and integration (optional)

## AWS IAM access control
- Kiam allowing IAM roles per pod
- IAM roles are assumed / requested and cached on controller nodes for improved security
- access to meta-data services is blocked / controlled on all nodes
- core IAM roles are maintained via CFN templates

## Network
- Calico using VxLAN incl. increased MTU
- allows way more containers per worker
- isolates container traffic from VPC by using VxLAN overlay
- no restrictions on IP space / sizing from the underlying VPC architecture

## Storage
- flexible EBS support incl. zone awareness
- EFS support via automated EFS provisioning for worker groups via CFN templates
- local storage provider for latency sensitive high performance workloads

## Ingress
- AWS Network Loadbalancer and Istio Ingress controllers
- No additional costs per exposed service
- Automated SSL Certificate handling via cert-manager incl. renewal etc.
- support for TCP services
- Client source IP available to workloads via HTTP header
- optional full service mesh

## Metrics
- Prometheus support for all components
- automated service discovery allowing instant access to common workload metrics
- Preconfigured community maintained Grafana dashboards for common services
- Preconfigured community maintained Alerts

## Logging
- all container logs are enhanced with Kubernetes metadata to provide context for each message
- flexible ElasticSearch setup, leveraging the ECK operator, for easy maintenance & minimal admin knowledge required, incl. automated backups to S3
- Kibana allowing easy search and dashboards for all logs, incl. pre configured index templates and index management
- central fluentd service providing queuing during highload as well as additional parsing options
- lightweight fluent-bit agents on each node requiring minimal resources forwarding logs secure via SSL to fluentd
