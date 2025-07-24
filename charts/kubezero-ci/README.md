# kubezero-ci

![Version: 0.8.25](https://img.shields.io/badge/Version-0.8.25-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

KubeZero umbrella chart for all things CI

**Homepage:** <https://kubezero.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stefan Reimer | <stefan@zero-downtime.net> |  |

## Requirements

Kubernetes: `>= 1.30.0`

| Repository | Name | Version |
|------------|------|---------|
| https://aquasecurity.github.io/helm-charts/ | trivy | 0.16.1 |
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://charts.jenkins.io | jenkins | 5.8.68 |
| https://dl.gitea.io/charts/ | gitea | 12.1.2 |
| https://docs.renovatebot.com/helm-charts | renovate | 41.43.0 |

# Jenkins
- default build retention 10 builds, 32days
- memory request 1.25GB
- dark theme
- trivy scanner incl. HTML reporting and publisher

# Gitea
 - robots.txt from https://opendev.org/opendev/system-config/raw/branch/master/docker/gitea/custom/public/robots.txt
 - integrated AI scraper blocking
 - ZDT branding using the CDN

# Verdaccio

## Authentication sealed-secret
```htpasswd -n -b -B -C 4 <username> <password> | kubeseal --raw --namespace verdaccio --name verdaccio-htpasswd```

## Resources

### JVM tuning in containers
- https://developers.redhat.com/blog/2017/04/04/openjdk-and-containers?extIdCarryOver=true&sc_cid=701f2000001Css5AAC

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| gitea.analytics.enabled | bool | `false` |  |
| gitea.checkDeprecation | bool | `false` |  |
| gitea.enabled | bool | `false` |  |
| gitea.extraVolumeMounts[0].mountPath | string | `"/data/gitea/public"` |  |
| gitea.extraVolumeMounts[0].name | string | `"gitea-public"` |  |
| gitea.extraVolumeMounts[0].readOnly | bool | `true` |  |
| gitea.extraVolumeMounts[1].mountPath | string | `"/data/gitea/templates/custom"` |  |
| gitea.extraVolumeMounts[1].name | string | `"gitea-templates"` |  |
| gitea.extraVolumeMounts[1].readOnly | bool | `true` |  |
| gitea.extraVolumes[0].configMap.name | string | `"gitea-kubezero-ci-public"` |  |
| gitea.extraVolumes[0].name | string | `"gitea-public"` |  |
| gitea.extraVolumes[1].configMap.name | string | `"gitea-kubezero-ci-templates"` |  |
| gitea.extraVolumes[1].name | string | `"gitea-templates"` |  |
| gitea.gitea.admin.existingSecret | string | `"gitea-admin-secret"` |  |
| gitea.gitea.config."ssh.minimum_key_sizes".RSA | int | `2047` |  |
| gitea.gitea.config.cache.ADAPTER | string | `"memory"` |  |
| gitea.gitea.config.database.DB_TYPE | string | `"sqlite3"` |  |
| gitea.gitea.config.log.LEVEL | string | `"warn"` |  |
| gitea.gitea.config.queue.TYPE | string | `"level"` |  |
| gitea.gitea.config.session.PROVIDER | string | `"memory"` |  |
| gitea.gitea.config.ui.DEFAULT_THEME | string | `"gitea-dark"` |  |
| gitea.gitea.config.ui.THEMES | string | `"gitea-light,gitea-dark"` |  |
| gitea.gitea.demo | bool | `false` |  |
| gitea.gitea.metrics.enabled | bool | `false` |  |
| gitea.gitea.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitea.image.rootless | bool | `true` |  |
| gitea.istio.blockApi | bool | `false` |  |
| gitea.istio.enabled | bool | `false` |  |
| gitea.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| gitea.istio.url | string | `"git.example.com"` |  |
| gitea.persistence.claimName | string | `"data-gitea-0"` |  |
| gitea.persistence.size | string | `"4Gi"` |  |
| gitea.postgresql-ha.enabled | bool | `false` |  |
| gitea.postgresql.enabled | bool | `false` |  |
| gitea.repliaCount | int | `1` |  |
| gitea.resources.limits.memory | string | `"2048Mi"` |  |
| gitea.resources.requests.cpu | string | `"200m"` |  |
| gitea.resources.requests.memory | string | `"1024Mi"` |  |
| gitea.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| gitea.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitea.service.http.port | int | `80` |  |
| gitea.strategy.type | string | `"Recreate"` |  |
| gitea.test.enabled | bool | `false` |  |
| gitea.valkey-cluster.enabled | bool | `false` |  |
| gitea.valkey.enabled | bool | `false` |  |
| jenkins.agent.annotations."cluster-autoscaler.kubernetes.io/safe-to-evict" | string | `"false"` |  |
| jenkins.agent.annotations."container.apparmor.security.beta.kubernetes.io/jnlp" | string | `"unconfined"` |  |
| jenkins.agent.containerCap | int | `2` |  |
| jenkins.agent.customJenkinsLabels[0] | string | `"podman-aws-trivy"` |  |
| jenkins.agent.defaultsProviderTemplate | string | `"podman-aws"` |  |
| jenkins.agent.garbageCollection.enabled | bool | `true` |  |
| jenkins.agent.idleMinutes | int | `30` |  |
| jenkins.agent.image.repository | string | `"public.ecr.aws/zero-downtime/jenkins-podman"` |  |
| jenkins.agent.image.tag | string | `"v0.7.2"` |  |
| jenkins.agent.inheritYamlMergeStrategy | bool | `true` |  |
| jenkins.agent.podName | string | `"podman-aws"` |  |
| jenkins.agent.podRetention | string | `"Default"` |  |
| jenkins.agent.resources.limits.cpu | string | `""` |  |
| jenkins.agent.resources.limits.memory | string | `""` |  |
| jenkins.agent.resources.requests.cpu | string | `""` |  |
| jenkins.agent.resources.requests.memory | string | `""` |  |
| jenkins.agent.runAsGroup | int | `1000` |  |
| jenkins.agent.runAsUser | int | `1000` |  |
| jenkins.agent.serviceAccount | string | `"jenkins-podman-aws"` |  |
| jenkins.agent.showRawYaml | bool | `false` |  |
| jenkins.agent.yamlMergeStrategy | string | `"merge"` |  |
| jenkins.agent.yamlTemplate | string | `"apiVersion: v1\nkind: Pod\nspec:\n  securityContext:\n    fsGroup: 1000\n  containers:\n  - name: jnlp\n    resources:\n      requests:\n        cpu: \"200m\"\n        memory: \"512Mi\"\n      limits:\n        cpu: \"4\"\n        memory: \"6144Mi\"\n        github.com/fuse: 1\n    volumeMounts:\n    - name: aws-token\n      mountPath: \"/var/run/secrets/sts.amazonaws.com/serviceaccount/\"\n      readOnly: true\n    - name: host-registries-conf\n      mountPath: \"/home/jenkins/.config/containers/registries.conf\"\n      readOnly: true\n  volumes:\n  - name: aws-token\n    projected:\n      sources:\n      - serviceAccountToken:\n          path: token\n          expirationSeconds: 86400\n          audience: \"sts.amazonaws.com\"\n  - name: host-registries-conf\n    hostPath:\n      path: /etc/containers/registries.conf\n      type: File"` |  |
| jenkins.controller.JCasC.configScripts.zdt-settings | string | `"jenkins:\n  noUsageStatistics: true\n  disabledAdministrativeMonitors:\n  - \"jenkins.security.ResourceDomainRecommendation\"\nappearance:\n  themeManager:\n    disableUserThemes: true\n    theme: \"dark\"\nunclassified:\n  openTelemetry:\n    configurationProperties: |-\n      otel.exporter.otlp.protocol=grpc\n      otel.instrumentation.jenkins.web.enabled=false\n    ignoredSteps: \"dir,echo,isUnix,pwd,properties\"\n    #endpoint: \"telemetry-jaeger-collector.telemetry:4317\"\n    exportOtelConfigurationAsEnvironmentVariables: false\n    #observabilityBackends:\n    # - jaeger:\n    #     jaegerBaseUrl: \"https://jaeger.example.com\"\n    #     name: \"KubeZero Jaeger\"\n    serviceName: \"Jenkins\"\n  buildDiscarders:\n    configuredBuildDiscarders:\n    - \"jobBuildDiscarder\"\n    - defaultBuildDiscarder:\n        discarder:\n          logRotator:\n            artifactDaysToKeepStr: \"32\"\n            artifactNumToKeepStr: \"10\"\n            daysToKeepStr: \"100\"\n            numToKeepStr: \"10\"\n"` |  |
| jenkins.controller.containerEnv[0].name | string | `"OTEL_LOGS_EXPORTER"` |  |
| jenkins.controller.containerEnv[0].value | string | `"none"` |  |
| jenkins.controller.containerEnv[1].name | string | `"OTEL_METRICS_EXPORTER"` |  |
| jenkins.controller.containerEnv[1].value | string | `"none"` |  |
| jenkins.controller.disableRememberMe | bool | `true` |  |
| jenkins.controller.enableRawHtmlMarkupFormatter | bool | `true` |  |
| jenkins.controller.image.tag | string | `"lts-alpine-jdk21"` |  |
| jenkins.controller.initContainerResources.limits.memory | string | `"1024Mi"` |  |
| jenkins.controller.initContainerResources.requests.cpu | string | `"50m"` |  |
| jenkins.controller.initContainerResources.requests.memory | string | `"256Mi"` |  |
| jenkins.controller.installPlugins[0] | string | `"kubernetes"` |  |
| jenkins.controller.installPlugins[10] | string | `"htmlpublisher"` |  |
| jenkins.controller.installPlugins[11] | string | `"build-discarder"` |  |
| jenkins.controller.installPlugins[12] | string | `"dark-theme"` |  |
| jenkins.controller.installPlugins[13] | string | `"matrix-auth"` |  |
| jenkins.controller.installPlugins[14] | string | `"reverse-proxy-auth-plugin"` |  |
| jenkins.controller.installPlugins[15] | string | `"opentelemetry"` |  |
| jenkins.controller.installPlugins[1] | string | `"kubernetes-credentials-provider"` |  |
| jenkins.controller.installPlugins[2] | string | `"workflow-aggregator"` |  |
| jenkins.controller.installPlugins[3] | string | `"git"` |  |
| jenkins.controller.installPlugins[4] | string | `"basic-branch-build-strategies"` |  |
| jenkins.controller.installPlugins[5] | string | `"pipeline-graph-view"` |  |
| jenkins.controller.installPlugins[6] | string | `"pipeline-stage-view"` |  |
| jenkins.controller.installPlugins[7] | string | `"configuration-as-code"` |  |
| jenkins.controller.installPlugins[8] | string | `"antisamy-markup-formatter"` |  |
| jenkins.controller.installPlugins[9] | string | `"prometheus"` |  |
| jenkins.controller.javaOpts | string | `"-XX:+UseContainerSupport -XX:+UseStringDeduplication -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-popups; default-src 'none'; img-src 'self' cdn.zero-downtime.net; style-src 'unsafe-inline';\""` |  |
| jenkins.controller.jenkinsOpts | string | `"--sessionTimeout=300 --sessionEviction=10800"` |  |
| jenkins.controller.prometheus.enabled | bool | `false` |  |
| jenkins.controller.resources.limits.memory | string | `"4096Mi"` |  |
| jenkins.controller.resources.requests.cpu | string | `"250m"` |  |
| jenkins.controller.resources.requests.memory | string | `"1280Mi"` |  |
| jenkins.controller.testEnabled | bool | `false` |  |
| jenkins.enabled | bool | `false` |  |
| jenkins.istio.agent.enabled | bool | `false` |  |
| jenkins.istio.agent.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| jenkins.istio.agent.url | string | `"jenkins-agent.example.com"` |  |
| jenkins.istio.enabled | bool | `false` |  |
| jenkins.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| jenkins.istio.url | string | `"jenkins.example.com"` |  |
| jenkins.istio.webhook.enabled | bool | `false` |  |
| jenkins.istio.webhook.gateway | string | `"istio-ingress/ingressgateway"` |  |
| jenkins.istio.webhook.url | string | `"jenkins-webhook.example.com"` |  |
| jenkins.persistence.size | string | `"4Gi"` |  |
| jenkins.rbac.readSecrets | bool | `true` |  |
| jenkins.serviceAccountAgent.create | bool | `true` |  |
| jenkins.serviceAccountAgent.name | string | `"jenkins-podman-aws"` |  |
| renovate.cronjob.concurrencyPolicy | string | `"Forbid"` |  |
| renovate.cronjob.jobBackoffLimit | int | `2` |  |
| renovate.cronjob.schedule | string | `"0 3 * * *"` |  |
| renovate.cronjob.successfulJobsHistoryLimit | int | `1` |  |
| renovate.enabled | bool | `false` |  |
| renovate.env.LOG_FORMAT | string | `"json"` |  |
| renovate.renovate.config | string | `"{\n}\n"` |  |
| renovate.securityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| trivy.enabled | bool | `false` |  |
| trivy.persistence.enabled | bool | `true` |  |
| trivy.persistence.size | string | `"2Gi"` |  |
| trivy.rbac.create | bool | `false` |  |
