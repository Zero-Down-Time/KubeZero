# kubezero-ci

![Version: 0.9.9](https://img.shields.io/badge/Version-0.9.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| https://cdn.zero-downtime.net/charts/ | kubezero-lib | 0.2.1 |
| https://charts.jenkins.io | jenkins | 5.8.142 |
| https://dl.gitea.io/charts/ | gitea | 12.5.0 |
| oci://code.forgejo.org/forgejo-helm | forgejo | 16.2.0 |
| oci://ghcr.io/renovatebot/charts | renovate | 46.25.5 |

# Jenkins
- default build retention 10 builds, 32days
- memory request 1.25GB
- dark theme
- warning-ng
- grype scanner

# Gitea
 - robots.txt from https://opendev.org/opendev/system-config/raw/branch/master/docker/gitea/custom/public/robots.txt
 - integrated AI scraper blocking
 - ZDT branding using the CDN

## Resources

### JVM tuning in containers
- https://developers.redhat.com/blog/2017/04/04/openjdk-and-containers?extIdCarryOver=true&sc_cid=701f2000001Css5AAC

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| forgejo.analytics.enabled | bool | `false` |  |
| forgejo.analytics.siteId | string | `"pleasesetasneeded"` |  |
| forgejo.checkDeprecation | bool | `false` |  |
| forgejo.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| forgejo.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| forgejo.enabled | bool | `false` |  |
| forgejo.extraContainerVolumeMounts[0].mountPath | string | `"/data/gitea/public"` |  |
| forgejo.extraContainerVolumeMounts[0].name | string | `"forgejo-public"` |  |
| forgejo.extraContainerVolumeMounts[0].readOnly | bool | `true` |  |
| forgejo.extraContainerVolumeMounts[1].mountPath | string | `"/data/gitea/templates/custom"` |  |
| forgejo.extraContainerVolumeMounts[1].name | string | `"forgejo-templates"` |  |
| forgejo.extraContainerVolumeMounts[1].readOnly | bool | `true` |  |
| forgejo.extraVolumes[0].configMap.name | string | `"forgejo-kubezero-ci-public"` |  |
| forgejo.extraVolumes[0].name | string | `"forgejo-public"` |  |
| forgejo.extraVolumes[1].configMap.name | string | `"forgejo-kubezero-ci-templates"` |  |
| forgejo.extraVolumes[1].name | string | `"forgejo-templates"` |  |
| forgejo.gitea.admin.existingSecret | string | `"forgejo-admin-secret"` |  |
| forgejo.gitea.config."service.explore".DISABLE_USERS_PAGE | string | `"true"` |  |
| forgejo.gitea.config."service.explore".REQUIRE_SIGNIN_VIEW | string | `"true"` |  |
| forgejo.gitea.config."ssh.minimum_key_sizes".RSA | int | `2047` |  |
| forgejo.gitea.config.cache.ADAPTER | string | `"memory"` |  |
| forgejo.gitea.config.database.DB_TYPE | string | `"sqlite3"` |  |
| forgejo.gitea.config.log.LEVEL | string | `"warn"` |  |
| forgejo.gitea.config.queue.TYPE | string | `"level"` |  |
| forgejo.gitea.config.service.DEFAULT_ORG_VISIBILITY | string | `"private"` |  |
| forgejo.gitea.config.service.DISABLE_REGISTRATION | string | `"true"` |  |
| forgejo.gitea.config.session.PROVIDER | string | `"memory"` |  |
| forgejo.gitea.config.ui.DEFAULT_THEME | string | `"forgejo-dark"` |  |
| forgejo.gitea.config.ui.THEMES | string | `"forgejo-light,forgejo-dark"` |  |
| forgejo.gitea.demo | bool | `false` |  |
| forgejo.gitea.metrics.enabled | bool | `false` |  |
| forgejo.gitea.metrics.serviceMonitor.enabled | bool | `true` |  |
| forgejo.image.rootless | bool | `true` |  |
| forgejo.image.tag | string | `"11.0.2"` |  |
| forgejo.istio.blockApi | bool | `false` |  |
| forgejo.istio.enabled | bool | `false` |  |
| forgejo.istio.gateway | string | `"istio-ingress/private-ingressgateway"` |  |
| forgejo.istio.url | string | `"git.example.com"` |  |
| forgejo.persistence.claimName | string | `"data-gitea-0"` |  |
| forgejo.persistence.size | string | `"4Gi"` |  |
| forgejo.replicaCount | int | `1` |  |
| forgejo.resources.limits.memory | string | `"2048Mi"` |  |
| forgejo.resources.requests.cpu | string | `"200m"` |  |
| forgejo.resources.requests.memory | string | `"1024Mi"` |  |
| forgejo.service.http.port | int | `80` |  |
| forgejo.strategy.type | string | `"Recreate"` |  |
| forgejo.test.enabled | bool | `false` |  |
| gitea.analytics.enabled | bool | `false` |  |
| gitea.analytics.siteId | string | `"pleasesetasneeded"` |  |
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
| gitea.gitea.config."service.explore".DISABLE_USERS_PAGE | string | `"true"` |  |
| gitea.gitea.config."service.explore".REQUIRE_SIGNIN_VIEW | string | `"true"` |  |
| gitea.gitea.config."ssh.minimum_key_sizes".RSA | int | `2047` |  |
| gitea.gitea.config.cache.ADAPTER | string | `"memory"` |  |
| gitea.gitea.config.database.DB_TYPE | string | `"sqlite3"` |  |
| gitea.gitea.config.log.LEVEL | string | `"warn"` |  |
| gitea.gitea.config.queue.TYPE | string | `"level"` |  |
| gitea.gitea.config.service.DEFAULT_ORG_VISIBILITY | string | `"private"` |  |
| gitea.gitea.config.service.DISABLE_REGISTRATION | string | `"true"` |  |
| gitea.gitea.config.session.PROVIDER | string | `"memory"` |  |
| gitea.gitea.config.ui.DEFAULT_THEME | string | `"gitea-dark"` |  |
| gitea.gitea.config.ui.THEMES | string | `"gitea-light,gitea-dark"` |  |
| gitea.gitea.demo | bool | `false` |  |
| gitea.gitea.metrics.enabled | bool | `false` |  |
| gitea.gitea.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitea.image.rootless | bool | `true` |  |
| gitea.image.tag | string | `"1.25.4"` |  |
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
| jenkins.agent.customJenkinsLabels[0] | string | `"podman-aws-grype"` |  |
| jenkins.agent.defaultsProviderTemplate | string | `"podman-aws"` |  |
| jenkins.agent.envVars[0].name | string | `"HOME"` |  |
| jenkins.agent.envVars[0].value | string | `"/home/jenkins/agent"` |  |
| jenkins.agent.garbageCollection.enabled | bool | `true` |  |
| jenkins.agent.idleMinutes | int | `30` |  |
| jenkins.agent.image.repository | string | `"public.ecr.aws/zero-downtime/jenkins-podman"` |  |
| jenkins.agent.image.tag | string | `"v0.8.5"` |  |
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
| jenkins.agent.yamlTemplate | string | `"apiVersion: v1\nkind: Pod\nspec:\n  securityContext:\n    fsGroup: 1000\n  containers:\n  - name: jnlp\n    resources:\n      requests:\n        cpu: \"200m\"\n        memory: \"512Mi\"\n      limits:\n        cpu: \"4\"\n        memory: \"6144Mi\"\n    volumeMounts:\n    - name: host-registries-conf\n      mountPath: \"/home/jenkins/.config/containers/registries.conf\"\n      readOnly: true\n  volumes:\n  - name: host-registries-conf\n    hostPath:\n      path: /etc/containers/registries.conf\n      type: File"` |  |
| jenkins.controller.JCasC.configScripts.zdt-settings | string | `"appearance:\n  themeManager:\n    disableUserThemes: true\n    theme: \"dark\"\n  loginTheme:\n    branding: \"https://cdn.zero-downtime.net/assets/kubezero/corgi-jenkins.svg\"\n    footer: |-\n      <div style=\"text-align:center;\">\n      Zero Down Time edition\n      </div>\n    useDefaultTheme: true\n  simpleTheme:\n    elements:\n    - cssText:\n        text: |-\n          .pipeline-new-node {\n              display: none;\n          }\n          .jenkins-header .app-jenkins-logo #jenkins-head-icon {\n              content: url('https://cdn.zero-downtime.net/assets/kubezero/corgi-jenkins.svg');\n          }\n    - faviconUrl:\n        url: \"https://cdn.zero-downtime.net/assets/kubezero/corgi-jenkins.svg\"\njenkins:\n  noUsageStatistics: true\n  disabledAdministrativeMonitors:\n  - \"jenkins.security.ResourceDomainRecommendation\"\nsecurity:\n  scriptApproval:\n    forceSandbox: true\n  contentSecurityPolicy:\n    advanced:\n    - custom:\n        rules:\n        - allowFetch:\n            allow:\n              byDomain:\n                domain: \"cdn.zero-downtime.net\"\n            directive: \"img-src\"\n    - reporting:\n        ignoreAnonymousReports: true\n    enforce: true\nunclassified:\n  openTelemetry:\n    configurationProperties: |-\n      otel.exporter.otlp.protocol=grpc\n      otel.instrumentation.jenkins.web.enabled=false\n    ignoredSteps: \"dir,echo,isUnix,pwd,properties\"\n    #endpoint: \"telemetry-jaeger-collector.telemetry:4317\"\n    exportOtelConfigurationAsEnvironmentVariables: false\n    #observabilityBackends:\n    # - jaeger:\n    #     jaegerBaseUrl: \"https://jaeger.example.com\"\n    #     name: \"KubeZero Jaeger\"\n    serviceName: \"Jenkins\"\n  buildDiscarders:\n    configuredBuildDiscarders:\n    - \"jobBuildDiscarder\"\n    - defaultBuildDiscarder:\n        discarder:\n          logRotator:\n            artifactDaysToKeepStr: \"32\"\n            artifactNumToKeepStr: \"10\"\n            daysToKeepStr: \"100\"\n            numToKeepStr: \"10\"\n"` |  |
| jenkins.controller.containerEnv[0].name | string | `"OTEL_LOGS_EXPORTER"` |  |
| jenkins.controller.containerEnv[0].value | string | `"none"` |  |
| jenkins.controller.containerEnv[1].name | string | `"OTEL_METRICS_EXPORTER"` |  |
| jenkins.controller.containerEnv[1].value | string | `"none"` |  |
| jenkins.controller.disableRememberMe | bool | `true` |  |
| jenkins.controller.enableRawHtmlMarkupFormatter | bool | `true` |  |
| jenkins.controller.image.tag | string | `"2.541.1-lts-alpine"` |  |
| jenkins.controller.initContainerResources.limits.memory | string | `"1024Mi"` |  |
| jenkins.controller.initContainerResources.requests.cpu | string | `"50m"` |  |
| jenkins.controller.initContainerResources.requests.memory | string | `"256Mi"` |  |
| jenkins.controller.installPlugins[0] | string | `"kubernetes"` |  |
| jenkins.controller.installPlugins[10] | string | `"configuration-as-code"` |  |
| jenkins.controller.installPlugins[11] | string | `"warnings-ng"` |  |
| jenkins.controller.installPlugins[12] | string | `"text-finder"` |  |
| jenkins.controller.installPlugins[13] | string | `"antisamy-markup-formatter"` |  |
| jenkins.controller.installPlugins[14] | string | `"prometheus"` |  |
| jenkins.controller.installPlugins[15] | string | `"htmlpublisher"` |  |
| jenkins.controller.installPlugins[16] | string | `"build-discarder"` |  |
| jenkins.controller.installPlugins[17] | string | `"csp"` |  |
| jenkins.controller.installPlugins[18] | string | `"dark-theme"` |  |
| jenkins.controller.installPlugins[19] | string | `"login-theme"` |  |
| jenkins.controller.installPlugins[1] | string | `"kubernetes-credentials-provider"` |  |
| jenkins.controller.installPlugins[20] | string | `"simple-theme-plugin"` |  |
| jenkins.controller.installPlugins[21] | string | `"matrix-auth"` |  |
| jenkins.controller.installPlugins[22] | string | `"oic-auth"` |  |
| jenkins.controller.installPlugins[23] | string | `"opentelemetry"` |  |
| jenkins.controller.installPlugins[2] | string | `"workflow-aggregator"` |  |
| jenkins.controller.installPlugins[3] | string | `"git"` |  |
| jenkins.controller.installPlugins[4] | string | `"git-forensics"` |  |
| jenkins.controller.installPlugins[5] | string | `"basic-branch-build-strategies"` |  |
| jenkins.controller.installPlugins[6] | string | `"pipeline-graph-view"` |  |
| jenkins.controller.installPlugins[7] | string | `"pipeline-stage-view"` |  |
| jenkins.controller.installPlugins[8] | string | `"http_request"` |  |
| jenkins.controller.installPlugins[9] | string | `"pipeline-utility-steps"` |  |
| jenkins.controller.javaOpts | string | `"-XX:+UseContainerSupport -XX:+UseStringDeduplication"` |  |
| jenkins.controller.jenkinsOpts | string | `"--sessionTimeout=300 --sessionEviction=10800"` |  |
| jenkins.controller.prometheus.enabled | bool | `false` |  |
| jenkins.controller.resources.limits.memory | string | `"4096Mi"` |  |
| jenkins.controller.resources.requests.cpu | string | `"250m"` |  |
| jenkins.controller.resources.requests.memory | string | `"1280Mi"` |  |
| jenkins.controller.sidecars.configAutoReload.image.tag | string | `"1.30.3"` |  |
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
| renovate.env.RENOVATE_USE_CLOUD_METADATA_SERVICES | string | `"false"` |  |
| renovate.renovate.config | string | `"{\n}\n"` |  |
| renovate.securityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
