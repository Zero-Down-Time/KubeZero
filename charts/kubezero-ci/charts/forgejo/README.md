# Forgejo Helm Chart <!-- omit from toc -->

- [Introduction](#introduction)
- [Update and versioning policy](#update-and-versioning-policy)
- [Dependencies](#dependencies)
- [Installing](#installing)
- [High Availability](#high-availability)
- [Configuration](#configuration)
  - [Default Configuration](#default-configuration)
    - [Database defaults](#database-defaults)
    - [Server defaults](#server-defaults)
    - [Metrics defaults](#metrics-defaults)
    - [Rootless Defaults](#rootless-defaults)
    - [Session, Cache and Queue](#session-cache-and-queue)
  - [Single-Pod Configurations](#single-pod-configurations)
  - [Additional _app.ini_ settings](#additional-appini-settings)
    - [User defined environment variables in app.ini](#user-defined-environment-variables-in-appini)
  - [External Database](#external-database)
  - [Ports and external url](#ports-and-external-url)
  - [SSH and Ingress](#ssh-and-ingress)
  - [SSH on crio based kubernetes cluster](#ssh-on-crio-based-kubernetes-cluster)
  - [Cache](#cache)
  - [Persistence](#persistence)
  - [Admin User](#admin-user)
  - [LDAP Settings](#ldap-settings)
  - [OAuth2 Settings](#oauth2-settings)
- [Configure commit signing](#configure-commit-signing)
- [Metrics and profiling](#metrics-and-profiling)
- [Pod annotations](#pod-annotations)
- [Themes](#themes)
- [Using Renovate](#using-renovate)
- [Parameters](#parameters)
  - [Global](#global)
  - [strategy](#strategy)
  - [Image](#image)
  - [Security](#security)
  - [Service](#service)
  - [Ingress](#ingress)
  - [deployment](#deployment)
  - [ServiceAccount](#serviceaccount)
  - [Persistence](#persistence-1)
  - [Init](#init)
  - [Signing](#signing)
  - [Gitea](#gitea)
  - [`app.ini` overrides](#appini-overrides)
  - [LivenessProbe](#livenessprobe)
  - [ReadinessProbe](#readinessprobe)
  - [StartupProbe](#startupprobe)
  - [Advanced](#advanced)
- [Contributing](#contributing)
- [Upgrading](#upgrading)
  - [To v16](#to-v16)
  - [To v15](#to-v15)
  - [To v14](#to-v14)
  - [To v13](#to-v13)
  - [To v12](#to-v12)
  - [To v11](#to-v11)
  - [To v10](#to-v10)
  - [To v9](#to-v9)
  - [To v8](#to-v8)
  - [To v7](#to-v7)
  - [To v6](#to-v6)

[Forgejo](https://forgejo.org/) is a community managed lightweight code hosting solution written in Go.
It is published under the MIT license.

## Introduction

This Helm chart is based on the [Gitea chart](https://gitea.com/gitea/helm-chart).
Yet it takes a completely different approach in providing a database and cache with dependencies.
Additionally, this chart allows to provide LDAP and admin user configuration with values.

## Update and versioning policy

The Forgejo helm chart versioning does not follow Forgejo's versioning.
The latest chart version can be looked up in <https://code.forgejo.org/forgejo-helm/-/packages/container/forgejo> or in the [repository releases](https://code.forgejo.org/forgejo-helm/forgejo-helm/releases).

The chart aims to follow Forgejo's releases closely.
There might be times when the chart is behind the latest Forgejo release.
This might be caused by different reasons, most often due to time constraints of the maintainers (remember, all work here is done voluntarily in the spare time of people).
If you're eager to use the latest Forgejo version earlier than this chart catches up, then change the tag in `values.yaml` to the latest Forgejo version.

## Dependencies

Forgejo can be run with an external database and cache.

## Installing

```sh
helm install forgejo oci://code.forgejo.org/forgejo-helm/forgejo
```

In case you want to supply values, you can reference a `values.yaml` file:

```sh
helm install forgejo -f values.yaml oci://code.forgejo.org/forgejo-helm/forgejo
```

When upgrading, please refer to the [Upgrading](#upgrading) section at the bottom of this document for major and breaking changes.

## High Availability

See the [HA Setup](docs/ha-setup.md) document for more details.

## Configuration

Forgejo offers lots of configuration options.
Every value described in the [Cheat Sheet](https://forgejo.org/docs/latest/admin/config-cheat-sheet/) can be set as a Helm value.
Configuration sections map to (lowercased) YAML blocks, while the keys themselves remain in all caps.

```yaml
gitea:
  config:
    # values in the DEFAULT section
    # (https://forgejo.org/docs/latest/admin/config-cheat-sheet/#overall-default)
    # are un-namespaced
    #
    APP_NAME: 'Forgejo: Git with a cup of tea'
    #
    # https://forgejo.org/docs/latest/admin/config-cheat-sheet/#repository-repository
    repository:
      ROOT: '~/forgejo-repositories'
    #
    # https://forgejo.org/docs/latest/admin/config-cheat-sheet/#repository---pull-request-repositorypull-request
    repository.pull-request:
      WORK_IN_PROGRESS_PREFIXES: 'WIP:,[WIP]:'
```

### Default Configuration

This chart will set a few defaults in the Forgejo configuration based on the service and ingress settings.
All defaults can be overwritten in `gitea.config`.

INSTALL_LOCK is always set to true because the configuration in this helm chart makes any configuration via installer superfluous.

_All default settings are made directly in the generated `app.ini`, not in the Values._

#### Database defaults

This chart uses the default SQLite database.

#### Server defaults

The server defaults are a bit more complex.
If ingress is `enabled`, the `ROOT_URL`, `DOMAIN` and `SSH_DOMAIN` will be set accordingly.
`HTTP_PORT` always defaults to `3000` as well as `SSH_PORT` to `22`.

```ini
[server]
APP_DATA_PATH = /data
DOMAIN = git.example.com
HTTP_PORT = 3000
PROTOCOL = http
ROOT_URL = http://git.example.com
SSH_DOMAIN = git.example.com
SSH_LISTEN_PORT = 22
SSH_PORT = 22
ENABLE_PPROF = false
```

#### Metrics defaults

The Prometheus `/metrics` endpoint is disabled by default.

```ini
[metrics]
ENABLED = false
```

#### Rootless Defaults

If `.Values.image.rootless: true`, then the following will occur. In case you use `.Values.image.fullOverride`, check that this works in your image:

- `$HOME` becomes `/data/gitea/git`

  [see deployment.yaml](./templates/gitea/deployment.yaml) template inside (init-)container "env" declarations

- `START_SSH_SERVER: true` (Unless explicitly overwritten by `gitea.config.server.START_SSH_SERVER`)

  [see \_helpers.tpl](./templates/_helpers.tpl) in `gitea.inline_configuration.defaults.server` definition

- `SSH_LISTEN_PORT: 2222` (Unless explicitly overwritten by `gitea.config.server.SSH_LISTEN_PORT`)

  [see \_helpers.tpl](./templates/_helpers.tpl) in `gitea.inline_configuration.defaults.server` definition

- `SSH_LOG_LEVEL` environment variable is not injected into the container

  [see deployment.yaml](./templates/gitea/deployment.yaml) template inside container "env" declarations

#### Session, Cache and Queue

The chart will fall back to the Forgejo defaults which use "memory" for `session` and `cache` and "level" for `queue`.

While these will work and even not cause immediate issues after startup, **they are not recommended for production use**.
Reasons being that a single pod will take on all the work for `session` and `cache` tasks in its available memory.
It is likely that the pod will run out of memory or will face substantial memory spikes, depending on the workload.
External tools such as `valkey-cluster` or `memcached` handle these workloads much better.

### Single-Pod Configurations

If HA is not needed/desired, the following configurations can be used to deploy a single-pod Forgejo instance.

For a production-ready single-pod Forgejo instance without external dependencies (using the built-in SQLite):

<details>

<summary>values.yml</summary>

```yaml
persistence:
  enabled: true

gitea:
  config:
    indexer:
      REPO_INDEXER_ENABLED: true
```

</details>

### Additional _app.ini_ settings

> **The [generic](https://forgejo.org/docs/latest/admin/config-cheat-sheet/#overall-default)
> section cannot be defined that way.**

Some settings inside _app.ini_ (like passwords or whole authentication configurations) must be considered sensitive and therefore should not be passed via plain text inside the _values.yaml_ file.
In times of _GitOps_ the values.yaml could be stored in a Git repository where sensitive data should never be accessible.

The Helm Chart supports this approach and let the user define custom sources like
Kubernetes Secrets to be loaded as environment variables during _app.ini_ creation or update.

```yaml
gitea:
  additionalConfigSources:
    - secret:
        secretName: forgejo-app-ini-oauth
    - configMap:
        name: forgejo-app-ini-plaintext
```

This would mount the two additional volumes (`oauth` and `some-additionals`) from different sources to the init container where the _app.ini_ gets updated.
All files mounted that way will be read and converted to environment variables and then added to the _app.ini_ using [environment-to-ini](https://github.com/go-gitea/gitea/tree/main/contrib/environment-to-ini).

The key of such additional source represents the section inside the _app.ini_.
The value for each key can be multiline ini-like definitions.

In example, the referenced `forgejo-app-ini-plaintext` could look like this.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: forgejo-app-ini-plaintext
data:
  session: |
    PROVIDER=memory
    SAME_SITE=strict
  cron.archive_cleanup: |
    ENABLED=true
```

Or when using a Kubernetes secret, having the same data structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: forgejo-security-related-configuration
type: Opaque
stringData:
  security: |
    PASSWORD_COMPLEXITY=off
  session: |
    SAME_SITE=strict
```

#### User defined environment variables in app.ini

Users are able to define their own environment variables, which are loaded into the containers.
We also support interacting directly with the generated _app.ini_.

To inject self defined variables into the _app.ini_ a certain format needs to be honored.
This is described in detail on the [env-to-ini](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/contrib/environment-to-ini) page.

Environment variables need to be prefixed with `FORGEJO`.

For example a database setting needs to have the following format:

```yaml
gitea:
  config:
    database:
      HOST: my.own.host
  additionalConfigFromEnvs:
    - name: FORGEJO__DATABASE__PASSWD
      valueFrom:
        secretKeyRef:
          name: postgres-secret
          key: password
```

Priority (highest to lowest) for defining app.ini variables:

1. Environment variables prefixed with `FORGEJO`

1. Additional config sources
1. Values defined in `gitea.config`

### External Database

A [supported external database](https://forgejo.org/docs/latest/admin/config-cheat-sheet/#database-database/) can be used instead of the built-in SQLite.
We recommend to use a PostgreSQL or MySQL database if you are planning a longterm use with 5+ active users and more than a few dozen repos.

Best practice is to use an Operator for database deployments, as this approach has many advantages for DB management in k8s compared to a standalone static one.

For Postgres, we can recommend the following ones:

- [CloudNative PG](https://github.com/cloudnative-pg/cloudnative-pg)
- [Crunchy Postgres Operator](https://github.com/CrunchyData/postgres-operator)

For MySQL:

- [MySQL k8s Operator](https://dev.mysql.com/doc/mysql-operator/en/)
- [Vitess](https://github.com/vitessio/vitess)

The following values settings must be used to reference an external DB:

```yaml
gitea:
  config:
    database:
      DB_TYPE: <dbtype> # supported values are mysql, postgres, mssql, sqlite3
      HOST: <host>
      NAME: <name>
      USER: <user>
      PASSWD: <passwd>
      SCHEMA: <schema> # optional
```

Usually you do not want to pass the credentials directly in the values file.
Instead, these can be referenced from a secret via

```yaml
gitea:
  additionalConfigSources:
    - secret:
        secretName: database
```

Note that when using this option, all DB options must be set in the secret.

### External Redis/Valkey

> [!TIP]
> For most use cases, the included adapters are fine.
> We only recommend this for medium-large instances.
> You can also start with the default ones and migrate at some point via a simple switchover - no data migration is necessary.

Instead of relying on the default adapters for cache & session, external Redis/Valkey instances can be used.

> [!NOTE]
> The name adapter 'redis' is hardcoded from within Forgejo and works just fine with a Valkey instance.

```yaml
gitea:
  queue:
    TYPE: redis
    CONN_STR: redis://<url>:<port>/0?

  cache:
    ADAPTER: redis
    HOST: redis://<url>:<port>/1

  session:
    PROVIDER: redis
    PROVIDER_CONFIG: redis://<url>:<port>/2
```

Examples for the sentiel and cluster variants:

```yaml
gitea:
  queue:
    TYPE: redis
    CONN_STR: redis+sentinel://<url>:<port>/0?mastername=<mastername>

  cache:
    ADAPTER: redis
    HOST: redis+sentinel://<url>:<port>/1?mastername=<mastername>

  session:
    PROVIDER: redis
    PROVIDER_CONFIG: redis+sentinel://<url>:<port>/2?mastername=<mastername>
```

> [!NOTE]
> The cluster variant can only use DB '0'

```yaml
gitea:
  queue:
    TYPE: redis
    CONN_STR: redis+cluster://<url>:<port>/0

  cache:
    ADAPTER: redis
    HOST: redis+cluster://<url>:<port>/0

  session:
    PROVIDER: redis
    PROVIDER_CONFIG: redis+cluster://<url>:<port>/0
```

### Ports and external url

By default port `3000` is used for web traffic and `22` for ssh.
Those can be changed:

```yaml
service:
  http:
    port: 3000
  ssh:
    port: 22
```

This helm chart automatically configures the clone urls to use the correct ports.
You can change these ports by hand using the `gitea.config` dict.
However you should know what you're doing.

### SSH and Ingress

If you're using ingress and want to use SSH, keep in mind, that ingress is not able to forward SSH Ports.
You will need a LoadBalancer like `metallb` and a setting in your ssh service annotations.

```yaml
service:
  ssh:
    annotations:
      metallb.io/allow-shared-ip: test
```

### SSH on crio based kubernetes cluster

If you use `crio` as container runtime it is not possible to read from a remote repository.
You should get an error message like this:

```bash
$ git clone git@k8s-demo.internal:admin/test.git
Cloning into 'test'...
Connection reset by 192.168.179.217 port 22
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

To solve this problem add the capability `SYS_CHROOT` to the `securityContext`.
More about this issue can be found at [`gitea/helm-chart#161`](https://gitea.com/gitea/helm-chart/issues/161).

### Cache

The chart will fall back to the Forgejo defaults which use "memory" for `session` and `cache` and "level" for `queue`.

### Persistence

Forgejo will be deployed as a deployment.
By simply enabling the persistence and setting the storage class according to your cluster everything else will be taken care of.
The following example will create a PVC as a part of the deployment.

Please note, that an empty `storageClass` in the persistence will result in kubernetes using your default storage class.

If you want to use your own storage class define it as follows:

```yaml
persistence:
  enabled: true
  storageClass: myOwnStorageClass
```

If you want to manage your own PVC you can simply pass the PVC name to the chart.

```yaml
persistence:
  enabled: true
  claimName: MyAwesomeForgejoClaim
```

In case that persistence has been disabled it will simply use an empty dir volume.

### Admin User

This chart creates a default admin user (`gitea_admin`) with a random password.
It is also possible to update the password for this user by upgrading or redeploying the chart.
You cannot use `admin` as username.

```yaml
gitea:
  admin:
    username: 'MyAwesomeForgejoAdmin'
    password: 'AReallyAwesomeForgejoPassword'
    email: 'forge@jo.com'
```

You can also use an existing Secret to configure the admin user:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: forgejo-admin-secret
type: Opaque
stringData:
  username: MyAwesomeForgejoAdmin
  password: AReallyAwesomeForgejoPassword
```

```yaml
gitea:
  admin:
    existingSecret: forgejo-admin-secret
```

To delete the admin user, set `gitea.admin.username` to an empty value and delete the user in the UI. `gitea.admin.existingSecret` must also be unset.

Whether you use the existing Secret or specify a username and password directly, there are three modes for how the admin user password is created or set.

- `keepUpdated` (the default) will set the admin user password, and reset it to the defined value every time the pod is recreated.
- `initialOnlyNoReset` will set the admin user password when creating it, but never try to update the password.
- `initialOnlyRequireReset` will set the admin user password when creating it, never update it, and require that the password be changed at the initial login.

These modes can be set like the following:

```yaml
gitea:
  admin:
    passwordMode: initialOnlyRequireReset
```

### LDAP Settings

Like the admin user the LDAP settings can be updated.
All LDAP values from <https://forgejo.org/docs/latest/admin/command-line/#admin> are available.

Multiple LDAP sources can be configured with additional LDAP list items.

```yaml
gitea:
  ldap:
    - name: MyAwesomeForgejoLdap
      securityProtocol: unencrypted
      host: '127.0.0.1'
      port: '389'
      userSearchBase: ou=Users,dc=example,dc=com
      userFilter: sAMAccountName=%s
      adminFilter: CN=Admin,CN=Group,DC=example,DC=com
      emailAttribute: mail
      bindDn: CN=ldap read,OU=Spezial,DC=example,DC=com
      bindPassword: JustAnotherBindPw
      usernameAttribute: CN
      publicSSHKeyAttribute: publicSSHKey
```

You can also use an existing secret to set the `bindDn` and `bindPassword`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: forgejo-ldap-secret
type: Opaque
stringData:
  bindDn: CN=ldap read,OU=Spezial,DC=example,DC=com
  bindPassword: JustAnotherBindPw
```

```yaml
gitea:
  ldap:
    - existingSecret: forgejo-ldap-secret
```

⚠️ Some options are just flags and therefore don't have any values.
If they are defined in `gitea.ldap` configuration, they will be passed to the Forgejo CLI without any value.
Affected options:

- notActive
- skipTlsVerify
- allowDeactivateAll
- synchronizeUsers
- attributesInBind

### OAuth2 Settings

Like the admin user, OAuth2 settings can be updated and disabled but not deleted.
Deleting OAuth2 settings has to be done in the UI.
[All OAuth2 values](https://forgejo.org/docs/latest/admin/command-line/#admin-auth-add-oauth) are available.

Multiple OAuth2 sources can be configured with additional OAuth list items.

```yaml
gitea:
  oauth:
    - name: 'MyAwesomeForgejoOAuth'
      provider: 'openidConnect'
      key: 'hello'
      secret: 'world'
      autoDiscoverUrl: 'https://forgejo.example.com/.well-known/openid-configuration'
      #useCustomUrls:
      #customAuthUrl:
      #customTokenUrl:
      #customProfileUrl:
      #customEmailUrl:
```

You can also use an existing secret to set the `key` and `secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: forgejo-oauth-secret
type: Opaque
stringData:
  key: hello
  secret: world
```

```yaml
gitea:
  oauth:
    - name: 'MyAwesomeForgejoOAuth'
      existingSecret: forgejo-oauth-secret
```

### Compatibility with OCP (OKD or OpenShift)

Normally OCP is automatically detected and the compatibility mode set accordingly. To enforce the OCP compatibility mode use the following configuration:

```yaml
global:
  compatibility:
    openshift:
      adaptSecurityContext: force
```

An OCP route to access Forgejo can be enabled with the following config:

```yaml
route:
  enabled: true
```

## Configure commit signing

When using the rootless image, the GPG key folder is not persistent by default.
If you want commits by Forgejo (e.g. initial commit) to be signed,
you need to provide a signing key:

```yaml
signing:
  enabled: false
  gpgHome: /data/git/.gnupg
```

By default this section is disabled to maintain backwards compatibility.

Regardless of the used container image the `signing` object allows to specify a private GPG key.
Either using the `signing.privateKey` to define the key inline, or referring to an existing secret containing the key data with `signing.existingSecret`.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: custom-forgejo-gpg-key
type: Opaque
stringData:
  privateKey: |-
    -----BEGIN PGP PRIVATE KEY BLOCK-----
    ...
    -----END PGP PRIVATE KEY BLOCK-----
```

```yaml
signing:
  existingSecret: custom-forgejo-gpg-key
```

To use the GPG key, Forgejo needs to be configured accordingly.
A detailed description can be found in the [documentation](https://forgejo.org/docs/latest/admin/signing/#general-configuration).

## Metrics and profiling

A Prometheus `/metrics` endpoint on the `HTTP_PORT` and `pprof` profiling endpoints on port 6060 can be enabled under `gitea`.
Beware that the metrics endpoint is exposed via the ingress, manage access using ingress annotations for example.

To deploy the `ServiceMonitor`, you first need to ensure that you have deployed `prometheus-operator` and its [CRDs](https://github.com/prometheus-operator/prometheus-operator#customresourcedefinitions).

```yaml
gitea:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

  config:
    server:
      ENABLE_PPROF: true
```

## Pod annotations

Annotations can be added to the Forgejo pod.

```yaml
gitea:
  podAnnotations: {}
```

## Themes

Custom themes can be added via k8s secrets and referencing them in `values.yaml`.

The [http provider](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) is useful here.

```yaml
extraVolumes:
  - name: forgejo-themes
    secret:
      secretName: forgejo-themes

extraVolumeMounts:
  - name: forgejo-themes
    readOnly: true
    mountPath: '/data/gitea/public/assets/css'
```

The secret can be created via `terraform`:

```hcl
resource "kubernetes_secret" "forgejo-themes" {
  metadata {
    name      = "forgejo-themes"
    namespace = "forgejo"
  }

  data = {
    "my-theme.css"      = data.http.forgejo-theme-light.body
    "my-theme-dark.css" = data.http.forgejo-theme-dark.body
    "my-theme-auto.css" = data.http.forgejo-theme-auto.body
  }

  type = "Opaque"
}


data "http" "forgejo-theme-light" {
  url = "<raw theme url>"

  request_headers = {
    Accept = "application/json"
  }
}

data "http" "forgejo-theme-dark" {
  url = "<raw theme url>"

  request_headers = {
    Accept = "application/json"
  }
}

data "http" "forgejo-theme-auto" {
  url = "<raw theme url>"

  request_headers = {
    Accept = "application/json"
  }
}
```

or natively via `kubectl`:

```bash
kubectl create secret generic forgejo-themes --from-file={{FULL-PATH-TO-CSS}} --namespace forgejo
```

## Using Renovate

Care must be taken when using [`renovate`](https://github.com/renovatebot/renovate) in combination with the `image.digest` field.
A [custom "regex" Manager](https://docs.renovatebot.com/modules/manager/regex/) is required to reference the correct underlying image reference.
By default, the tag of the rootful image is fetched. This does not play well with `image.rootless: true` (the default), i.e. renovate fetches the tag of a different images than the one actually in use!
This will result in the rooless image being pulled behind the scences, even though `image.rootless: true` is set.

Here's an examplary `values.yml` definition which makes use of a digest:

```yaml
image:
  registry: code.forgejo.org
  repository: forgejo/forgejo
  tag: <tag>
  digest: sha256:f597c14a403c2fdee9a62dae8bae29d6442f7b2cc85872cc9bb535a24cb1630e
```

To account for this circumstance, `.Values.image.tag` should be expliclity suffixed with `-rootless`, e.g., `tag: <tag>-rootless`.

By default Renovate adds digest after `<tag>`.
To comply with the Forgejo helm chart definition of the digest parameter, a "customManagers" definition is required:

```json
"customManagers": [
  {
    "customType": "regex",
    "description": "Apply an explicit forgejo digest field match",
    "fileMatch": ["values\\.ya?ml"],
    "matchStrings": ["(?<depName>forgejo\\/forgejo)\\n(?<indentation>\\s+)tag: (?<currentValue>[^@].*?)\\n\\s+digest: (?<currentDigest>sha256:[a-f0-9]+)"],
    "datasourceTemplate": "docker",
    "packageNameTemplate": "code.forgejo.org/{{depName}}",
    "autoReplaceStringTemplate": "{{depName}}\n{{indentation}}tag: {{newValue}}\n{{indentation}}digest: {{#if newDigest}}{{{newDigest}}}{{else}}{{{currentDigest}}}{{/if}}"
  }
]
```

## Parameters

### Global

| Name                      | Description                                                               | Value           |
| ------------------------- | ------------------------------------------------------------------------- | --------------- |
| `global.imageRegistry`    | global image registry override                                            | `""`            |
| `global.imagePullSecrets` | global image pull secrets override; can be extended by `imagePullSecrets` | `[]`            |
| `global.storageClass`     | global storage class override                                             | `""`            |
| `global.hostAliases`      | global hostAliases which will be added to the pod's hosts files           | `[]`            |
| `namespaceOverride`       | String to fully override common.names.namespace                           | `""`            |
| `clusterDomain`           | cluster domain                                                            | `cluster.local` |

### strategy

Do not use `RollingUpdate` for `strategy.type`, it will cause issues with the deployment.

| Name                                    | Description    | Value      |
| --------------------------------------- | -------------- | ---------- |
| `strategy.type`                         | strategy type  | `Recreate` |
| `strategy.rollingUpdate.maxSurge`       | maxSurge       | `100%`     |
| `strategy.rollingUpdate.maxUnavailable` | maxUnavailable | `0`        |

### Image

| Name                 | Description                                                                                                                                                      | Value              |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| `image.registry`     | image registry, e.g. gcr.io,docker.io                                                                                                                            | `code.forgejo.org` |
| `image.repository`   | Image to start for this pod                                                                                                                                      | `forgejo/forgejo`  |
| `image.tag`          | Visit: [Image tag](https://code.forgejo.org/forgejo/-/packages/container/forgejo/versions). Defaults to `appVersion` within Chart.yaml.                          | `""`               |
| `image.digest`       | Image digest. Allows to pin the given image tag. Useful for having control over mutable tags like `latest`                                                       | `""`               |
| `image.pullPolicy`   | Image pull policy                                                                                                                                                | `IfNotPresent`     |
| `image.rootless`     | Whether or not to pull the rootless version of Forgejo                                                                                                           | `true`             |
| `image.fullOverride` | Completely overrides the image registry, path/image, tag and digest. **Adjust `image.rootless` accordingly and review [Rootless defaults](#rootless-defaults).** | `""`               |
| `imagePullSecrets`   | Secret to use for pulling the image                                                                                                                              | `[]`               |

### Security

Security context is only usable with rootless image due to image design.

| Name                         | Description                                                     | Value  |
| ---------------------------- | --------------------------------------------------------------- | ------ |
| `podSecurityContext.fsGroup` | Set the shared file system group for all containers in the pod. | `1000` |
| `containerSecurityContext`   | Security context                                                | `{}`   |
| `securityContext`            | Run init and Forgejo containers as a specific securityContext   | `{}`   |
| `podDisruptionBudget`        | Pod disruption budget                                           | `{}`   |

### Service

| Name                                    | Description                                                                                                                                                                                         | Value       |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `service.http.type`                     | Kubernetes service type for web traffic                                                                                                                                                             | `ClusterIP` |
| `service.http.port`                     | Port number for web traffic                                                                                                                                                                         | `3000`      |
| `service.http.clusterIP`                | ClusterIP setting for http autosetup for deployment                                                                                                                                                 | `nil`       |
| `service.http.loadBalancerIP`           | LoadBalancer IP setting                                                                                                                                                                             | `nil`       |
| `service.http.nodePort`                 | NodePort for http service                                                                                                                                                                           | `nil`       |
| `service.http.externalTrafficPolicy`    | If `service.http.type` is `NodePort` or `LoadBalancer`, set this to `Local` to enable source IP preservation                                                                                        | `nil`       |
| `service.http.externalIPs`              | External IPs for service                                                                                                                                                                            | `nil`       |
| `service.http.ipFamilyPolicy`           | HTTP service dual-stack policy                                                                                                                                                                      | `nil`       |
| `service.http.ipFamilies`               | HTTP service dual-stack family selection,for dual-stack parameters see official kubernetes [dual-stack concept documentation](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | `nil`       |
| `service.http.loadBalancerSourceRanges` | Source range filter for http loadbalancer                                                                                                                                                           | `[]`        |
| `service.http.annotations`              | HTTP service annotations                                                                                                                                                                            | `{}`        |
| `service.http.labels`                   | HTTP service additional labels                                                                                                                                                                      | `{}`        |
| `service.http.loadBalancerClass`        | Loadbalancer class                                                                                                                                                                                  | `nil`       |
| `service.http.extraPorts`               | Additional ports                                                                                                                                                                                    | `[]`        |
| `service.ssh.type`                      | Kubernetes service type for ssh traffic                                                                                                                                                             | `ClusterIP` |
| `service.ssh.port`                      | Port number for ssh traffic                                                                                                                                                                         | `22`        |
| `service.ssh.clusterIP`                 | ClusterIP setting for ssh autosetup for deployment                                                                                                                                                  | `nil`       |
| `service.ssh.loadBalancerIP`            | LoadBalancer IP setting                                                                                                                                                                             | `nil`       |
| `service.ssh.nodePort`                  | NodePort for ssh service                                                                                                                                                                            | `nil`       |
| `service.ssh.externalTrafficPolicy`     | If `service.ssh.type` is `NodePort` or `LoadBalancer`, set this to `Local` to enable source IP preservation                                                                                         | `nil`       |
| `service.ssh.externalIPs`               | External IPs for service                                                                                                                                                                            | `nil`       |
| `service.ssh.ipFamilyPolicy`            | SSH service dual-stack policy                                                                                                                                                                       | `nil`       |
| `service.ssh.ipFamilies`                | SSH service dual-stack family selection,for dual-stack parameters see official kubernetes [dual-stack concept documentation](https://kubernetes.io/docs/concepts/services-networking/dual-stack/).  | `nil`       |
| `service.ssh.hostPort`                  | HostPort for ssh service                                                                                                                                                                            | `nil`       |
| `service.ssh.loadBalancerSourceRanges`  | Source range filter for ssh loadbalancer                                                                                                                                                            | `[]`        |
| `service.ssh.annotations`               | SSH service annotations                                                                                                                                                                             | `{}`        |
| `service.ssh.labels`                    | SSH service additional labels                                                                                                                                                                       | `{}`        |
| `service.ssh.loadBalancerClass`         | Loadbalancer class                                                                                                                                                                                  | `nil`       |

### Ingress

| Name                                 | Description             | Value             |
| ------------------------------------ | ----------------------- | ----------------- |
| `ingress.enabled`                    | Enable ingress          | `false`           |
| `ingress.className`                  | Ingress class name      | `nil`             |
| `ingress.annotations`                | Ingress annotations     | `{}`              |
| `ingress.hosts[0].host`              | Default Ingress host    | `git.example.com` |
| `ingress.hosts[0].paths[0].path`     | Default Ingress path    | `/`               |
| `ingress.hosts[0].paths[0].pathType` | Ingress path type       | `Prefix`          |
| `ingress.hosts[0].paths[0].port`     | Target port for Ingress | `http`            |
| `ingress.tls`                        | Ingress tls settings    | `[]`              |

### Gateway-API HTTPRoute

| Name                           | Description                                                                                                        | Value        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------ | ------------ |
| `httpRoute.enabled`            | Enables Gateway API HTTPRoute as a replacement for traditional Ingress resources                                   | `false`      |
| `httpRoute.annotations`        | Annotations to add to the HTTPRoute resource                                                                       | `{}`         |
| `httpRoute.parentRefs`         | List of parentRefs for the HTTPRoute, typically referencing the Gateway(name, namespace)                           | `[]`         |
| `httpRoute.hostnames`          | Hostnames this HTTPRoute applies to                                                                                | `[]`         |
| `httpRoute.matches.path.type`  | Type of path match (e.g., PathPrefix or Exact or RegularExpression)                                                | `PathPrefix` |
| `httpRoute.matches.path.value` | Path value for matching incoming requests                                                                          | `/`          |
| `httpRoute.matches.timeouts`   | Object containing timeouts.                                                                                        | `{}`         |
| `httpRoute.filters`            | Filters to apply on HTTP requests, such as header rewrites or request redirects                                    | `[]`         |
| `httpRoute.port`               | Target port for HTTPRoute. Must be a port number.                                                                  | `nil`        |
| `httpRoute.terminate`          | wether the Gateway listener terminates the TLS connection. This just affects the Forgejo `ROOT_URL` configuration. | `true`       |

### Gateway-API TCPRoute

| Name                   | Description                                                                                           | Value   |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | ------- |
| `tcpRoute.enabled`     | Enables Gateway API TCPRoute for SSH traffic                                                          | `false` |
| `tcpRoute.annotations` | Annotations to add to the TCPRoute resource                                                           | `{}`    |
| `tcpRoute.parentRefs`  | List of parentRefs for the TCPRoute, typically referencing the Gateway (name, namespace, sectionName) | `[]`    |
| `tcpRoute.port`        | Target port for TCPRoute. Must be a port number. Defaults to service.ssh.port.                        | `nil`   |

### Route

| Name                                      | Description                                                                                                                                                                                       | Value      |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `route.enabled`                           | Enable route                                                                                                                                                                                      | `false`    |
| `route.annotations`                       | Route annotations                                                                                                                                                                                 | `{}`       |
| `route.host`                              | Host to use for the route (will be assigned automatically by OKD / OpenShift is not defined)                                                                                                      | `nil`      |
| `route.wildcardPolicy`                    | Wildcard policy if any for the route, currently only 'Subdomain' or 'None' is allowed.                                                                                                            | `nil`      |
| `route.tls.termination`                   | termination type (see [OKD documentation](https://docs.okd.io/latest/rest_api/network_apis/route-route-openshift-io-v1.html#spec-tls))                                                            | `edge`     |
| `route.tls.insecureEdgeTerminationPolicy` | the desired behavior for insecure connections to a route (e.g. with http)                                                                                                                         | `Redirect` |
| `route.tls.existingSecret`                | the name of a predefined secret of type kubernetes.io/tls with both key (tls.crt and tls.key) set accordingly (if defined attributes 'certificate', 'caCertificate' and 'privateKey' are ignored) | `nil`      |
| `route.tls.certificate`                   | PEM encoded single certificate                                                                                                                                                                    | `nil`      |
| `route.tls.privateKey`                    | PEM encoded private key                                                                                                                                                                           | `nil`      |
| `route.tls.caCertificate`                 | PEM encoded CA certificate or chain that issued the certificate                                                                                                                                   | `nil`      |
| `route.tls.destinationCACertificate`      | PEM encoded CA certificate used to verify the authenticity of final end point when 'termination' is set to 'passthrough' (ignored otherwise)                                                      | `nil`      |

### deployment

Do not set `replicaCount` greater than `1`, Forgejo is not HA ready and this will cause issues with the deployment.

| Name                                       | Description                                            | Value |
| ------------------------------------------ | ------------------------------------------------------ | ----- |
| `resources`                                | Kubernetes resources                                   | `{}`  |
| `schedulerName`                            | Use an alternate scheduler, e.g. "stork"               | `""`  |
| `nodeSelector`                             | NodeSelector for the deployment                        | `{}`  |
| `tolerations`                              | Tolerations for the deployment                         | `[]`  |
| `affinity`                                 | Affinity for the deployment                            | `{}`  |
| `topologySpreadConstraints`                | TopologySpreadConstraints for the deployment           | `[]`  |
| `dnsPolicy`                                | dnsPolicy for the deployment                           | `""`  |
| `dnsConfig`                                | dnsConfig for the deployment                           | `{}`  |
| `priorityClassName`                        | priorityClassName for the deployment                   | `""`  |
| `deployment.env`                           | Additional environment variables to pass to containers | `[]`  |
| `deployment.terminationGracePeriodSeconds` | How long to wait until forcefully kill the pod         | `60`  |
| `deployment.labels`                        | Labels for the deployment                              | `{}`  |
| `deployment.annotations`                   | Annotations for the Forgejo deployment to be created   | `{}`  |
| `replicaCount`                             | number of replicas for the deployment                  | `1`   |

### ServiceAccount

| Name                                          | Description                                                                                                                               | Value   |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `serviceAccount.create`                       | Enable the creation of a ServiceAccount                                                                                                   | `false` |
| `serviceAccount.name`                         | Name of the created ServiceAccount, defaults to release name. Can also link to an externally provided ServiceAccount that should be used. | `""`    |
| `serviceAccount.automountServiceAccountToken` | Enable/disable auto mounting of the service account token                                                                                 | `false` |
| `serviceAccount.imagePullSecrets`             | Image pull secrets, available to the ServiceAccount                                                                                       | `[]`    |
| `serviceAccount.annotations`                  | Custom annotations for the ServiceAccount                                                                                                 | `{}`    |
| `serviceAccount.labels`                       | Custom labels for the ServiceAccount                                                                                                      | `{}`    |

### Persistence

| Name                                              | Description                                                                                             | Value                  |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------- |
| `persistence.enabled`                             | Enable persistent storage                                                                               | `true`                 |
| `persistence.create`                              | Whether to create the persistentVolumeClaim for shared storage                                          | `true`                 |
| `persistence.mount`                               | Whether the persistentVolumeClaim should be mounted (even if not created)                               | `true`                 |
| `persistence.claimName`                           | Use an existing claim to store repository information                                                   | `gitea-shared-storage` |
| `persistence.size`                                | Size for persistence to store repo information                                                          | `10Gi`                 |
| `persistence.accessModes`                         | AccessMode for persistence                                                                              | `["ReadWriteOnce"]`    |
| `persistence.labels`                              | Labels for the persistence volume claim to be created                                                   | `{}`                   |
| `persistence.annotations.helm.sh/resource-policy` | Resource policy for the persistence volume claim                                                        | `keep`                 |
| `persistence.storageClass`                        | Name of the storage class to use                                                                        | `nil`                  |
| `persistence.subPath`                             | Subdirectory of the volume to mount at                                                                  | `nil`                  |
| `persistence.volumeName`                          | Name of persistent volume in PVC                                                                        | `""`                   |
| `extraContainers`                                 | Additional sidecar containers to run in the pod                                                         | `[]`                   |
| `extraVolumes`                                    | Additional volumes to mount to the Forgejo deployment                                                   | `[]`                   |
| `extraContainerVolumeMounts`                      | Mounts that are only mapped into the Forgejo runtime/main container, to e.g. override custom templates. | `[]`                   |
| `extraInitVolumeMounts`                           | Mounts that are only mapped into the init-containers. Can be used for additional preconfiguration.      | `[]`                   |
| `extraVolumeMounts`                               | **DEPRECATED** Additional volume mounts for init containers and the Forgejo main container              | `[]`                   |

### Init

| Name                                       | Description                                                                          | Value   |
| ------------------------------------------ | ------------------------------------------------------------------------------------ | ------- |
| `initPreScript`                            | Bash shell script copied verbatim to the start of the init-container.                | `""`    |
| `initContainers.resources.limits`          | initContainers.limits Kubernetes resource limits for init containers                 | `{}`    |
| `initContainers.resources.requests.cpu`    | initContainers.requests.cpu Kubernetes cpu resource limits for init containers       | `100m`  |
| `initContainers.resources.requests.memory` | initContainers.requests.memory Kubernetes memory resource limits for init containers | `128Mi` |

### Signing

| Name                     | Description                                                       | Value              |
| ------------------------ | ----------------------------------------------------------------- | ------------------ |
| `signing.enabled`        | Enable commit/action signing                                      | `false`            |
| `signing.gpgHome`        | GPG home directory                                                | `/data/git/.gnupg` |
| `signing.privateKey`     | Inline private GPG key for signed internal Git activity           | `""`               |
| `signing.existingSecret` | Use an existing secret to store the value of `signing.privateKey` | `""`               |

### Gitea

| Name                                     | Description                                                                                                                   | Value                |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `gitea.admin.username`                   | Username for the Forgejo admin user                                                                                           | `gitea_admin`        |
| `gitea.admin.existingSecret`             | Use an existing secret to store admin user credentials                                                                        | `nil`                |
| `gitea.admin.password`                   | Password for the Forgejo admin user                                                                                           | `""`                 |
| `gitea.admin.email`                      | Email for the Forgejo admin user                                                                                              | `gitea@local.domain` |
| `gitea.admin.passwordMode`               | Mode for how to set/update the admin user password. Options are: initialOnlyNoReset, initialOnlyRequireReset, and keepUpdated | `keepUpdated`        |
| `gitea.metrics.enabled`                  | Enable Forgejo metrics                                                                                                        | `false`              |
| `gitea.metrics.serviceMonitor.enabled`   | Enable Forgejo metrics service monitor                                                                                        | `false`              |
| `gitea.metrics.serviceMonitor.namespace` | Namespace in which Prometheus is running                                                                                      | `""`                 |
| `gitea.ldap`                             | LDAP configuration                                                                                                            | `[]`                 |
| `gitea.oauth`                            | OAuth configuration                                                                                                           | `[]`                 |
| `gitea.additionalConfigSources`          | Additional configuration from secret or configmap                                                                             | `[]`                 |
| `gitea.additionalConfigFromEnvs`         | Additional configuration sources from environment variables                                                                   | `[]`                 |
| `gitea.podAnnotations`                   | Annotations for the Forgejo pod                                                                                               | `{}`                 |
| `gitea.ssh.logLevel`                     | Configure OpenSSH's log level. Only available for root-based Forgejo image.                                                   | `INFO`               |

### `app.ini` overrides

Every value described in the [Cheat
Sheet](https://forgejo.org/docs/latest/admin/config-cheat-sheet/) can be
set as a Helm value. Configuration sections map to (lowercased) YAML
blocks, while the keys themselves remain in all caps.

| Name                                 | Description                                                                                         | Value                               |
| ------------------------------------ | --------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `gitea.config.APP_NAME`              | Application name, used in the page title                                                            | `Forgejo: Beyond coding. We forge.` |
| `gitea.config.RUN_MODE`              | Application run mode, affects performance and debugging: `dev` or `prod`                            | `prod`                              |
| `gitea.config.repository`            | General repository settings                                                                         | `{}`                                |
| `gitea.config.cors`                  | Cross-origin resource sharing settings                                                              | `{}`                                |
| `gitea.config.ui`                    | User interface settings                                                                             | `{}`                                |
| `gitea.config.markdown`              | Markdown parser settings                                                                            | `{}`                                |
| `gitea.config.server`                | General server settings                                                                             | `{}`                                |
| `gitea.config.database`              | Database configuration (only necessary with an [externally managed DB](#external-database)).        | `{}`                                |
| `gitea.config.indexer`               | Settings for what content is indexed and how                                                        | `{}`                                |
| `gitea.config.queue`                 | Job queue configuration                                                                             | `{}`                                |
| `gitea.config.admin`                 | Admin user settings                                                                                 | `{}`                                |
| `gitea.config.security`              | Site security settings                                                                              | `{}`                                |
| `gitea.config.camo`                  | Settings for the [camo](https://github.com/cactus/go-camo) media proxy server (disabled by default) | `{}`                                |
| `gitea.config.openid`                | Configuration for authentication with OpenID (disabled by default)                                  | `{}`                                |
| `gitea.config.oauth2_client`         | OAuth2 client settings                                                                              | `{}`                                |
| `gitea.config.service`               | Configuration for miscellaneous Forgejo services                                                    | `{}`                                |
| `gitea.config.ssh.minimum_key_sizes` | SSH minimum key sizes                                                                               | `{}`                                |
| `gitea.config.webhook`               | Webhook settings                                                                                    | `{}`                                |
| `gitea.config.mailer`                | Mailer configuration (disabled by default)                                                          | `{}`                                |
| `gitea.config.email.incoming`        | Configuration for handling incoming mail (disabled by default)                                      | `{}`                                |
| `gitea.config.cache`                 | Cache configuration                                                                                 | `{}`                                |
| `gitea.config.session`               | Session/cookie handling                                                                             | `{}`                                |
| `gitea.config.picture`               | User avatar settings                                                                                | `{}`                                |
| `gitea.config.project`               | Project board defaults                                                                              | `{}`                                |
| `gitea.config.attachment`            | Issue and PR attachment configuration                                                               | `{}`                                |
| `gitea.config.log`                   | Logging configuration                                                                               | `{}`                                |
| `gitea.config.cron`                  | Cron job configuration                                                                              | `{}`                                |
| `gitea.config.git`                   | Global settings for Git                                                                             | `{}`                                |
| `gitea.config.metrics`               | Settings for the Prometheus endpoint (disabled by default)                                          | `{}`                                |
| `gitea.config.api`                   | Settings for the Swagger API documentation endpoints                                                | `{}`                                |
| `gitea.config.oauth2`                | Settings for the [OAuth2 provider](https://forgejo.org/docs/latest/admin/oauth2-provider/)          | `{}`                                |
| `gitea.config.i18n`                  | Internationalization settings                                                                       | `{}`                                |
| `gitea.config.markup`                | Configuration for advanced markup processors                                                        | `{}`                                |
| `gitea.config.highlight.mapping`     | File extension to language mapping overrides for syntax highlighting                                | `{}`                                |
| `gitea.config.time`                  | Locale settings                                                                                     | `{}`                                |
| `gitea.config.migrations`            | Settings for Git repository migrations                                                              | `{}`                                |
| `gitea.config.federation`            | Federation configuration                                                                            | `{}`                                |
| `gitea.config.packages`              | Package registry settings                                                                           | `{}`                                |
| `gitea.config.mirror`                | Configuration for repository mirroring                                                              | `{}`                                |
| `gitea.config.lfs`                   | Large File Storage configuration                                                                    | `{}`                                |
| `gitea.config.repo-avatar`           | Repository avatar storage configuration                                                             | `{}`                                |
| `gitea.config.avatar`                | User/org avatar storage configuration                                                               | `{}`                                |
| `gitea.config.storage`               | General storage settings                                                                            | `{}`                                |
| `gitea.config.proxy`                 | Proxy configuration (disabled by default)                                                           | `{}`                                |
| `gitea.config.actions`               | Configuration for [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/)                  | `{}`                                |
| `gitea.config.other`                 | Uncategorized configuration options                                                                 | `{}`                                |

### LivenessProbe

| Name                                      | Description                                      | Value  |
| ----------------------------------------- | ------------------------------------------------ | ------ |
| `gitea.livenessProbe.enabled`             | Enable liveness probe                            | `true` |
| `gitea.livenessProbe.tcpSocket.port`      | Port to probe for liveness                       | `http` |
| `gitea.livenessProbe.initialDelaySeconds` | Initial delay before liveness probe is initiated | `200`  |
| `gitea.livenessProbe.timeoutSeconds`      | Timeout for liveness probe                       | `1`    |
| `gitea.livenessProbe.periodSeconds`       | Period for liveness probe                        | `10`   |
| `gitea.livenessProbe.successThreshold`    | Success threshold for liveness probe             | `1`    |
| `gitea.livenessProbe.failureThreshold`    | Failure threshold for liveness probe             | `10`   |

### ReadinessProbe

| Name                                       | Description                                       | Value          |
| ------------------------------------------ | ------------------------------------------------- | -------------- |
| `gitea.readinessProbe.enabled`             | Enable readiness probe                            | `true`         |
| `gitea.readinessProbe.httpGet.path`        | Path to probe for readiness                       | `/api/healthz` |
| `gitea.readinessProbe.httpGet.port`        | Port to probe for readiness                       | `http`         |
| `gitea.readinessProbe.initialDelaySeconds` | Initial delay before readiness probe is initiated | `5`            |
| `gitea.readinessProbe.timeoutSeconds`      | Timeout for readiness probe                       | `1`            |
| `gitea.readinessProbe.periodSeconds`       | Period for readiness probe                        | `10`           |
| `gitea.readinessProbe.successThreshold`    | Success threshold for readiness probe             | `1`            |
| `gitea.readinessProbe.failureThreshold`    | Failure threshold for readiness probe             | `3`            |

### StartupProbe

| Name                                     | Description                                     | Value   |
| ---------------------------------------- | ----------------------------------------------- | ------- |
| `gitea.startupProbe.enabled`             | Enable startup probe                            | `false` |
| `gitea.startupProbe.tcpSocket.port`      | Port to probe for startup                       | `http`  |
| `gitea.startupProbe.initialDelaySeconds` | Initial delay before startup probe is initiated | `60`    |
| `gitea.startupProbe.timeoutSeconds`      | Timeout for startup probe                       | `1`     |
| `gitea.startupProbe.periodSeconds`       | Period for startup probe                        | `10`    |
| `gitea.startupProbe.successThreshold`    | Success threshold for startup probe             | `1`     |
| `gitea.startupProbe.failureThreshold`    | Failure threshold for startup probe             | `10`    |

### Advanced

| Name               | Description                                                        | Value     |
| ------------------ | ------------------------------------------------------------------ | --------- |
| `checkDeprecation` | Whether to run this basic validation check.                        | `true`    |
| `test.enabled`     | Whether to use test-connection Pod.                                | `true`    |
| `test.image.name`  | Image name for the wget container used in the test-connection Pod. | `busybox` |
| `test.image.tag`   | Image tag for the wget container used in the test-connection Pod.  | `latest`  |
| `extraDeploy`      | Array of extra objects to deploy with the release.                 | `[]`      |

## Contributing

Expected workflow is: Fork -> Patch -> Push -> Pull Request

See [CONTRIBUTORS GUIDE](CONTRIBUTING.md) for details.

Hop into [our Matrix room](https://matrix.to/#/#forgejo-helm-chart:matrix.org) if you have any questions or want to get involved.

## Upgrading

This section lists major and breaking changes of each Helm Chart version.
Please read them carefully to upgrade successfully, especially the change of the **default database backend**!
If you miss this, blindly upgrading may delete your Postgres instance and you may lose your data!

### To v16

This chart now uses Forgejo v14 by default.

### To v15

This chart now uses Forgejo v13 by default.

The admin password is now randomly generated if not set explicitly.
Because `gitea.admin.passwordMode` is set to `keepUpdated` by default the upgrade will set a new random admin password if you haven't set one explicitly.
If you like to disable the admin user you now need to set `gitea.admin.username` to an empty value.

### To v14

PostgreSQL and PostgreSQL HA subcharts have been removed.
You need to manually migrate to an external PostgreSQL instance.

Valkey and Valkey Cluster charts have been removed.
You need to provide your own instances if you like to continue to use Valkey.
This also changes the default issue indexer type back to `bleve`.

The rationale behind this change is [Bitnami's decision to discontinue free images](https://github.com/bitnami/containers/issues/83267) which are the core element of all referenced charts of theirs.
Besides, this change also does not align with the open philosophy of Forgejo.
In addition, removing included sub-charts reduces maintaince overhead for this chart in general and forces users to think about the desired architecture in more detail rather than just switching a toggle.

If you are using one of the included subcharts, our recommendations are as follows:

- For the Valkey charts: either deploy your own standalone instances (NB: right now, no good alternatives exists yet) or switch to the built-in defaults.
  You should likely be just fine and not face any usage issues.
- For the DB charts: Migration efforts are needed as the DB is a core compenent of the overall deployment.
  Regardless of the type, we recommend to follow these steps:
  1. (optional) Plan for a downtime.
  1. Stop the deployment, i.e. scale down the instances to 0 to avoid writes during the migration.
  1. Export a full DB dump.
     One option to extract the dump out of the cluster is to use `kubectl cp`.
     Many operators allow restoring/bootstrapping from a dump in S3, so storing the dump there is advisable.
  1. Decide for an operator.
  1. Check the operator docs how to bootstrap/restore from a dump.

More detailed migrations instructions are out-of-scope for this document as they would differ between operators and DB type.
Feel free to open an issue if you need assistance of certain steps are unclear.

We again apologize for the inconvenience this causes but there is no real alternative path for us to take, regardless of whether we would keep sub-charts in general or not.

### To v13

This chart now uses Forgejo v12 by default.

The PostgreSQL HA got a major version bump.
Please read the migration guide <https://artifacthub.io/packages/helm/bitnami/postgresql-ha#to-16-0-0>.

Migrated from Redis/Redis Cluster to Valkey/Valkey Cluster charts.
While marked as breaking, there should be no need to migrate data explicity.
Cache will start to refill automatically.

Forgejo v7 and Forgejo helm chart v7 are now EOL.

### To v12

You need Forgejo v11+ to use this Helm Chart version.
Forgejo v10 is now EOL.

### To v11

PostgreSQL and PostgreSQL HA are now using PostgreSQL v17.
Please read PostgresSQL upgrade guide before upgrading.

You need Forgejo v10+ to use this Helm Chart version.
Forgejo v9 is now EOL.

ClusterIP is now empty instead of `None` for http and ssh service.
Unsupported api versions for `Ingress` and `PodDisruptionBudget` are removed.
`Ingress` and `Service` are now using named ports.
The ReadinessProbe is now using the `/api/healthz` endpoint.

### To v10

You need Forgejo v9+ to use this Helm Chart version.
Forgejo v8 is now EOL.

### To v9

Namespaces for all resources are now set to `common.names.namespace` by default.

### To v8

You need Forgejo v8+ to use this Helm Chart version.
Use the v7 Helm Chart for Forgejo v7.

### To v7

The Forgejo docker image is pulled from `code.forgejo.org` instead of `codeberg.org`.

### To v6

You need Forgejo v7+ to use this Helm Chart version.
Use the v5 Helm Chart for Forgejo v1.21.
