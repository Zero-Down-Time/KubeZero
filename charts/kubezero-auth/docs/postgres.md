# Upgrade Postgres major version

## backup

- shell into running postgres-auth pod
```
export PGPASSWORD="$POSTGRES_POSTGRES_PASSWORD"
cd /tmp
pg_dumpall -U postgres > /tmp/backup
```

- store backup off-site
```
kubectl cp keycloak/kubezero-auth-postgresql-0:/tmp/backup postgres-backup
```

## upgrade

- upgrade auth chart
- set replica of the keycloak statefulSet to 0
- set replica of the postgres-auth statefulSet to 0
- delete postgres-auth PVC and POD to flush old DB

## restore

- restore replica of postgres-auth statefulSet
- copy backup to new PVC
```
kubectl cp postgres-backup keycloak/kubezero-auth-postgresql-0:/tmp/backup
```

- shell into running postgres-auth pod
```
export PGPASSWORD="$POSTGRES_POSTGRES_PASSWORD"
cd /tmp
psql -U postgres
```

- drop database `keycloak` in case the keycloak instances connected early
```
DROP database keycloak
```

- actual restore
```
psql -U postgres -d postgres -f backup
```

- reset replia of keycloak statefulSet or force ArgoCD sync

success.
