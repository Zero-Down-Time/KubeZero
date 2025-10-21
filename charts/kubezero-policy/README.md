# kubezero-policy

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for Kyverno

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.33.0-0`

| Repository | Name | Version |
|------------|------|---------|
|  | policies | 0.1.1 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://kyverno.github.io/kyverno/ | kyverno | 3.5.2 |

# Kyverno

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kyverno.admissionController.container.extraArgs.leaderElectionRetryPeriod | string | `"30s"` |  |
| kyverno.admissionController.revisionHistoryLimit | int | `2` |  |
| kyverno.backgroundController.extraArgs.leaderElectionRetryPeriod | string | `"30s"` |  |
| kyverno.backgroundController.revisionHistoryLimit | int | `2` |  |
| kyverno.cleanupController.extraArgs.leaderElectionRetryPeriod | string | `"30s"` |  |
| kyverno.cleanupController.rbac.clusterRole.extraResources[0].apiGroups[0] | string | `"postgresql.cnpg.io"` |  |
| kyverno.cleanupController.rbac.clusterRole.extraResources[0].resources[0] | string | `"backups"` |  |
| kyverno.cleanupController.rbac.clusterRole.extraResources[0].verbs[0] | string | `"delete"` |  |
| kyverno.cleanupController.rbac.clusterRole.extraResources[0].verbs[1] | string | `"list"` |  |
| kyverno.cleanupController.rbac.clusterRole.extraResources[0].verbs[2] | string | `"watch"` |  |
| kyverno.cleanupController.revisionHistoryLimit | int | `2` |  |
| kyverno.config.preserve | bool | `false` |  |
| kyverno.config.webhookAnnotations."argocd.argoproj.io/installation-id" | string | `"KubeZero-ArgoCD"` |  |
| kyverno.crds.migration.enabled | bool | `false` |  |
| kyverno.enabled | bool | `false` |  |
| kyverno.features.logging.format | string | `"json"` |  |
| kyverno.grafana.enabled | bool | `false` |  |
| kyverno.policyReportsCleanup.enabled | bool | `false` |  |
| kyverno.reportsController.enabled | bool | `false` |  |
| kyverno.reportsController.revisionHistoryLimit | int | `2` |  |
| kyverno.webhooksCleanup.autoDeleteWebhooks.enabled | bool | `true` |  |
| kyverno.webhooksCleanup.enabled | bool | `false` |  |
