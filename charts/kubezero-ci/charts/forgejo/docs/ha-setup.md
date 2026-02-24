# High Availability

> [!WARNING]
> Forgejo is not HA-ready yet.
> This means that important processes (queue, cron, cache) do not use an active leader-follower logic.
> When Forgejo is run in HA with multiple deployments sharing the same database and storage, race conditions and duplicate > executions are likely to happen.
> We won't stop you from trying it out, but have warned you about potential consequences, which are hard to debug.

All components (in-memory DB, volume/asset storage, code indexer) used by Forgejo must be deployed in a HA-ready fashion to achieve a full HA-ready Forgejo deployment.
You are responsible for deploying these alongside Forgejo and connecting them accordingly.
The following document explains how to achieve this for all individual components.

> [!NOTE]
> With v14 of the Chart, the built-in HA-subcharts have been removed, to protect against optimistic HA-deployment approaches.

## Requirements for HA

Storage-wise, the HA-Forgejo setup requires a RWX file-system, so that the stateless deployment instances are ablet operate on a single storage source.
In addition, the following components are required for full HA-readiness:

- A HA-ready issue (and optionally code) indexer: `elasticsearch` or `meilisearch`
- A HA-ready external object/asset storage (S3, `minio`) (optionally, assets can also be stored on the RWX file-system)
- A HA-ready cache and queue (e.g. `valkey-cluster`)
- A HA-ready database

The following sections discuss each of the components in more detail.
Note that for each component discussed, the shown configurations only provides a (working) starting point, not necessarily the most optimal setup.
We try to optimize this document over time as we have gained more experience with HA setups from users.

## Indexers (Issues and code/repo)

The default code indexer `bleve` is not able to allow multiple connections and hence cannot be used in a HA setup.
Alternatives are `elasticsearch` and `meilisearch`.
Unless you have an existing `elasticsearch` cluster, we recommend using `meilisearch` as it is faster and requires way less resources.

> [!NOTE]
> `meilisearch` only supports the `ISSUE_INDEXER` and not the `REPO_INDEXER` (which is responsible for code search) (yet) ([tracking issue](https://codeberg.org/forgejo/forgejo/issues/8302)).
> This means that the `REPO_INDEXER` must be disabled for a HA setup right now.
> An alternative to the two options above for the `ISSUE_INDEXER` is `"db"`, however we recommend to just go with `meilisearch` in this case and to not bother the DB with such indexing tasks.

To configure `meilisearch` within Forgejo, do the following:

```yml
gitea:
  config:
    indexer:
      ISSUE_INDEXER_CONN_STR: <http://meilisearch.<namespace>.svc.cluster.local:7700>
      ISSUE_INDEXER_ENABLED: true
      ISSUE_INDEXER_TYPE: meilisearch
      REPO_INDEXER_ENABLED: false
      # REPO_INDEXER_TYPE: meilisearch # not yet working
```

Unfortunately `meilisearch` [cannot be deployed in HA as of now](https://github.com/orgs/meilisearch/discussions/617).
Nevertheless it allows for multiple Forgejo requests at the same time and is therefore required in a HA setup.

## Cache, session and queue

A `valkey-cluster` instance is required for the in-memory cache.

You can also configure an external `valkey` instance.
To do so, you need to set the following configuration values yourself:

- `gitea.config.queue.TYPE`: valkey`
- `gitea.config.queue.CONN_STR`: `<your valkey connection string>`

- `gitea.config.session.PROVIDER`: `valkey`
- `gitea.config.session.PROVIDER_CONFIG`: `<your valkey connection string>`

- `gitea.config.cache.ENABLED`: `true`
- `gitea.config.cache.ADAPTER`: `valkey`
- `gitea.config.cache.HOST`: `<your valkey connection string>`

## Object and asset storage

Object/asset storage refers to the storage of attachments, avatars, LFS files, etc.
While these can be stored on disk, it is recommended to use an external S3-compatible object storage for such, to save disk writes and space.

By default the chart provisions a single RWO volume to store everything (repos, avatars, packages, etc.).
This volume cannot be mounted by multiple pods.
Hence, a RWX volume is required.

> [!NOTE]
> Double-check that the file permissions are set correctly on the RWX volume!
> That is everything should be owned by the `git` user which usually has `uid=1000` and `gid=1000`.

To use `minio` (i.e. self-hosted S3) you need to deploy and configure an external `minio` instance yourself and explicitly define the `STORAGE_TYPE` values as shown below.

Note that `MINIO_BUCKET` here is just a name and does not refer to a S3 bucket.
It's the root access point for all objects belonging to the respective application, i.e., to Forgejo in this case.

```yaml
gitea:
  config:
    attachment:
      STORAGE_TYPE: minio
    lfs:
      STORAGE_TYPE: minio
    picture:
      AVATAR_STORAGE_TYPE: minio
    'storage.packages':
      STORAGE_TYPE: minio

    storage:
      MINIO_ENDPOINT: <minio-headless.<namespace>.svc.cluster.local:9000>
      MINIO_LOCATION: <location>
      MINIO_ACCESS_KEY_ID: <access key>
      MINIO_SECRET_ACCESS_KEY: <secret key>
      MINIO_BUCKET: <bucket name>
      MINIO_USE_SSL: false
```

## Database

To connect an external DB, the following settings must be set:

```yml
gitea:
  config:
    database:
      DB_TYPE: postgres
      HOST: <host>
      NAME: <name>
      USER: <user>
```
