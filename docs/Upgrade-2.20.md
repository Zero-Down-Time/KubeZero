# KubeZero V2.20 / Kubernetes 1.20

## New features
- Support for [Service Account Tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) incl. federation with AWS IAM  
This allows pods to assume IAM roles without the need of additional services like kiam.
- Cert-manager integration now supports [cross-account issuer](https://cert-manager.io/docs/configuration/acme/dns01/route53/#cross-account-access) for AWS route53
- Optional Proxy Protocol support for Ingress Loadbalancers, which allows preserving the real client IP and at the same time solves the hairpin routing issues of the AWS NLBs, see [Istio blog](https://istio.io/v1.9/blog/2020/show-source-ip/)
- Optional taints for each workergroup allowing to reserve certain nodes for dedicated workloads. The minimum required KubeZero pods will still be scheduled eg. CSI drivers, logging and metric agents.

## New modules
### Storage
New module to provide various storage related components from here on. The first provider is a minimal subset of OpenEBS.  

The *LVM Local PV provisioner* allows the use of any available LVM storage on worker nodes as local PVs.
 
### MQ

- [NATS](https://docs.nats.io/jetstream/jetstream) services incl. jetstream engine, Grafana dashboards etc.  
This also incl. optional MQTT support.

- RabbitMQ

### TimeCapsule
Provides backup solutions for KubeZero clusters, like  
Scheduled snapshots for EBS backed PVCs incl. custom retention and restore.

## Removed modules
- local-path-provisioner -> functionality replaced by OpenEBS LVM
- local-volume-provisioner -> functionality replaced by OpenEBS LVM

## Changelog

### General
- version bumps of all modules
- cert-manager, ebs-csi and efs-csi driver now leverage service account tokens and do not rely on kiam anymore

### Logging
- version bumps for ElasticSearch, Kibana, ECK, fluentd and fluent-bit
- various fixes and tuning to improve reliability of the fluentd aggregator layer

### Istio
- hardened and optimized settings for Envoy gateway proxies
- improved deployment strategy to reduce errors during upgrades
- Added various Grafana Dashboards
- version bump to 1.10.3

### Metrics
- Added support for Prometheus PushGateway (optional)
- Added various dashboards for KubeZero modules
- Updated / improved dashboard organization incl. folders and tags
- Grafana Dashboards are now all provided via configmaps, no more state required, also no more manual changes persisted
- Grafana now allows anonymous read-only access
- all dashboards default to `now-1h` and prohibit less than 30s refresh cycles
- Custom dashboards can easily be provided by simple installing a ConfigMap along with workloads in any namespace


# Upgrade - CloudBender
- Set the specific wanted Kubernetes version in the controller config to eg. `v1.20.8`
- configure your AWS CLI profile as well as your kubectl context to point to the cluster you want to upgrade  
and verify your config via `aws sts get-caller-identity` and `kubectl cluster-info`

- run `./scripts/upgrade_120.sh`

- ensure that the S3 bucket for the cluster backups does *NOT* block public access:  
`aws s3api get-public-access-block --bucket <cluster-backup-bucket>`  
needs to have:

```
"BlockPublicAcls": false
"IgnorePublicAcls": false
```
- update the CFN stack kube-control-plane for your cluster

### Single node control plane
- a new controller instance will automatically be launched and replace the current controller as part of the CFN update

### Clustered control plane
- replace controller instances one by one in no particular order
- once confirmed that the upgraded 1.20 control plane is working as expected update the clustered control plane CFN stack once more with `LBType: none` to remove the AWS NLB fronting the Kubernetes API which is not required anymore.

## Upgrade Cloudbender continue
- upgrade all `kube-worker*` CFN stacks
- replace worker nodes in a rolling fashion via. drain / terminate and rinse-repeat

# Upgrade KubeZero
1. Prepare upgrade
- Remove legacy monitoring configmaps
```
kubectl delete cm -n monitoring -l grafana_dashboard=1
```

- Remove previous Grafana stateful config
```
kubectl delete pvc metrics-grafana -n monitoring
```

- Remove legacy Istio Envoyfilter
```
kubectl delete envoyfilter -A -l operator.istio.io/version=1.6.9
```

- ensure that the latest kubezero.yaml output from CloudBender is present under `clusters/$CLUSTER` and no legacy cloudbender.yaml is around anymore.  
If ArgoCD is used make sure the `valuesFiles` settings in the top-level values.yaml matches the files under `clusters/$CLUSTER`

2. Update CRDs of all enabled components:  
`./bootstrap.sh crds all clusters/$CLUSTER`

3. Upgrade all KubeZero modules:  
- without ArgoCD:  
  - `./bootstrap.sh deploy all clusters/$CLUSTER`  
- with ArgoCD:  

  - ArgoCD itself: `./bootstrap.sh deploy argocd clusters/$CLUSTER`
  - push latest cluster config to your git repo
  - trigger sync in ArgoCD incl. *prune* starting with the KubeZero root app  
( only if auto-sync is not enabled )

## Verification / Tests
- check if all pods are RUNNING
- check any Ingress services
- ...
