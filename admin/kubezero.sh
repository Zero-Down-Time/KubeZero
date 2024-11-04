#!/bin/bash -e

if [ -n "$DEBUG" ]; then
  set -x
  LOG="--v=5"
fi

# include helm lib
. /var/lib/kubezero/libhelm.sh

# Export vars to ease use in debug_shell etc
export WORKDIR=/tmp/kubezero
export HOSTFS=/host
export CHARTS=/charts
export KUBE_VERSION=$(kubeadm version -o json | jq -r .clientVersion.gitVersion)
export KUBE_VERSION_MINOR=$(echo $KUBE_VERSION | sed -e 's/\.[0-9]*$//')

export KUBECONFIG="${HOSTFS}/root/.kube/config"

# etcd
export ETCDCTL_API=3
export ETCDCTL_CACERT=${HOSTFS}/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=${HOSTFS}/etc/kubernetes/pki/apiserver-etcd-client.crt
export ETCDCTL_KEY=${HOSTFS}/etc/kubernetes/pki/apiserver-etcd-client.key

mkdir -p ${WORKDIR}

# Generic retry utility
retry() {
  local tries=$1
  local waitfor=$2
  local timeout=$3
  shift 3
  while true; do
    type -tf $1 >/dev/null && { timeout $timeout $@ && return; } || { $@ && return; }
    let tries=$tries-1
    [ $tries -eq 0 ] && return 1
    sleep $waitfor
  done
}


_kubeadm() {
  kubeadm $@ --config /etc/kubernetes/kubeadm.yaml --rootfs ${HOSTFS} $LOG
}


# Render cluster config
render_kubeadm() {
  local phase=$1

  helm template $CHARTS/kubeadm --output-dir ${WORKDIR} \
    -f ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml \
    --set patches=/etc/kubernetes/patches

  # Assemble kubeadm config
  cat /dev/null > ${HOSTFS}/etc/kubernetes/kubeadm.yaml
  for f in Cluster KubeProxy Kubelet; do
    # echo "---" >> /etc/kubernetes/kubeadm.yaml
    cat ${WORKDIR}/kubeadm/templates/${f}Configuration.yaml >> ${HOSTFS}/etc/kubernetes/kubeadm.yaml
  done

  if [[ "$phase" =~ ^(bootstrap|restore)$ ]]; then
    cat ${WORKDIR}/kubeadm/templates/InitConfiguration.yaml >> ${HOSTFS}/etc/kubernetes/kubeadm.yaml
  fi

  # "uncloak" the json patches after they got processed by helm
  for s in apiserver controller-manager scheduler; do
    yq eval '.json' ${WORKDIR}/kubeadm/templates/patches/kube-${s}1\+json.yaml > /tmp/_tmp.yaml && \
      mv /tmp/_tmp.yaml ${WORKDIR}/kubeadm/templates/patches/kube-${s}1\+json.yaml
  done
}


parse_kubezero() {
  export CLUSTERNAME=$(yq eval '.global.clusterName // .clusterName' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export PLATFORM=$(yq eval '.global.platform // "nocloud"' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export HIGHAVAILABLE=$(yq eval '.global.highAvailable // .highAvailable // "false"' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export ETCD_NODENAME=$(yq eval '.etcd.nodeName' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export NODENAME=$(yq eval '.nodeName' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export PROVIDER_ID=$(yq eval '.providerID // ""' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)
  export AWS_IAM_AUTH=$(yq eval '.api.awsIamAuth.enabled // "false"' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml)

  # From here on bail out, allows debug_shell even in error cases
  set -e
}


# Shared steps before calling kubeadm
pre_kubeadm() {
  # update all apiserver addons first
  cp -r ${WORKDIR}/kubeadm/templates/apiserver ${HOSTFS}/etc/kubernetes

  # aws-iam-authenticator enabled ?
  if [ "$AWS_IAM_AUTH" == "true" ]; then

    # Initialize webhook
    if [ ! -f ${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.crt ]; then
      ${HOSTFS}/usr/bin/aws-iam-authenticator init -i ${CLUSTERNAME}
      mv key.pem ${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.key
      mv cert.pem ${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.crt
    fi

    # Patch the aws-iam-authenticator config with the actual cert.pem
    yq eval -Mi ".clusters[0].cluster.certificate-authority-data = \"$(cat ${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.crt| base64 -w0)\"" ${HOSTFS}/etc/kubernetes/apiserver/aws-iam-authenticator.yaml
  fi

  # copy patches to host to make --rootfs of kubeadm work
  cp -r ${WORKDIR}/kubeadm/templates/patches ${HOSTFS}/etc/kubernetes
}


# Shared steps after calling kubeadm
post_kubeadm() {
  # KubeZero resources
  for f in ${WORKDIR}/kubeadm/templates/resources/*.yaml; do
    kubectl apply -f $f $LOG
  done

  # Patch coreDNS addon, ideally we prevent kubeadm to reset coreDNS to its defaults
  kubectl patch deployment coredns -n kube-system --patch-file ${WORKDIR}/kubeadm/templates/patches/coredns0.yaml $LOG
}


kubeadm_upgrade() {
  # pre upgrade hook

  ### Remove with 1.31
  # migrate kubezero CM to kubezero NS
  # migrate ArgoCD app from values to valuesObject
  create_ns kubezero

  if [ "$ARGOCD" == "True" ]; then
    kubectl get app kubezero -n argocd -o yaml > $WORKDIR/kubezero-argo-app.yaml
    if [ "$(yq '(.spec.source.helm | has "values")' $WORKDIR/kubezero-argo-app.yaml)" == "true" ]; then
      yq '.spec.source.helm.valuesObject = (.spec.source.helm.values | from_yaml)' \
        $WORKDIR/kubezero-argo-app.yaml | kubectl apply --server-side --force-conflicts -f -

      kubectl patch app kubezero -n argocd --type json -p='[{"op": "remove", "path": "/spec/source/helm/values"}]'
      kubectl delete cm kubezero-values -n kube-system > /dev/null || true
      kubectl create configmap -n kubezero kubezero-values || true
    fi

  else
    kubectl get cm kubezero-values -n kubezero > /dev/null || \
      { kubectl get cm kubezero-values -n kube-system -o yaml | \
        sed 's/^  namespace: kube-system/  namespace: kubezero/' | \
        kubectl create -f - && \
        kubectl delete cm kubezero-values -n kube-system ; }
  fi
  ###

  # get current values, argo app over cm
  get_kubezero_values $ARGOCD

  # tumble new config through migrate.py
  migrate_argo_values.py < "$WORKDIR"/kubezero-values.yaml > "$WORKDIR"/new-kubezero-values.yaml

  # Update kubezero-values CM
  kubectl get cm -n kubezero kubezero-values -o=yaml | \
    yq e '.data."values.yaml" |= load_str("/tmp/kubezero/new-kubezero-values.yaml")' | \
    kubectl apply --server-side --force-conflicts -f -

  if [ "$ARGOCD" == "True" ]; then
    # update argo app
    export kubezero_chart_version=$(yq .version $CHARTS/kubezero/Chart.yaml)
    kubectl get application kubezero -n argocd -o yaml | \
      yq '.spec.source.helm.valuesObject |= load("/tmp/kubezero/new-kubezero-values.yaml") | .spec.source.targetRevision = strenv(kubezero_chart_version)' \
      > $WORKDIR/new-argocd-app.yaml
    kubectl apply --server-side --force-conflicts -f $WORKDIR/new-argocd-app.yaml

    # finally remove annotation to allow argo to sync again
    kubectl patch app kubezero -n argocd --type json -p='[{"op": "remove", "path": "/metadata/annotations"}]' || true
  fi

  # Local node upgrade
  render_kubeadm upgrade

  pre_kubeadm

  # Upgrade - we upload the new config first so we can use --patch during 1.30
  _kubeadm init phase upload-config kubeadm

  kubeadm upgrade apply --yes --patches /etc/kubernetes/patches $KUBE_VERSION --rootfs ${HOSTFS} $LOG

  post_kubeadm

  # install re-certed kubectl config for root
  cp ${HOSTFS}/etc/kubernetes/super-admin.conf ${HOSTFS}/root/.kube/config

  # post upgrade hook
  [ -f /var/lib/kubezero/post-upgrade.sh ] && . /var/lib/kubezero/post-upgrade.sh

  # Cleanup after kubeadm on the host
  rm -rf ${HOSTFS}/etc/kubernetes/tmp

  echo "Successfully upgraded kubeadm control plane."

  # TODO
  # Send Notification currently done via CloudBender -> SNS -> Slack
  # Better deploy https://github.com/opsgenie/kubernetes-event-exporter and set proper routes and labels on this Job

  # Removed:
  # - update oidc do we need that ?
}


control_plane_node() {
  CMD=$1

  render_kubeadm $CMD

  # Ensure clean slate if bootstrap, restore PKI otherwise
  if [[ "$CMD" =~ ^(bootstrap)$ ]]; then
    rm -rf ${HOSTFS}/var/lib/etcd/member

  else
    # restore latest backup
    retry 10 60 30 restic restore latest --no-lock -t / # --tag $KUBE_VERSION_MINOR

    # get timestamp from latest snap for debug / message
    # we need a way to surface this info to eg. Slack
    #snapTime="$(restic snapshots latest --json | jq -r '.[].time')"

    # Make last etcd snapshot available
    cp ${WORKDIR}/etcd_snapshot ${HOSTFS}/etc/kubernetes

    # Put PKI in place
    cp -r ${WORKDIR}/pki ${HOSTFS}/etc/kubernetes

    # Always use kubeadm kubectl config to never run into chicken egg with custom auth hooks
    cp ${WORKDIR}/super-admin.conf ${HOSTFS}/root/.kube/config

    # Only restore etcd data during "restore" and none exists already
    if [[ "$CMD" =~ ^(restore)$ ]]; then
      if [ ! -d ${HOSTFS}/var/lib/etcd/member ]; then
        etcdctl snapshot restore ${HOSTFS}/etc/kubernetes/etcd_snapshot \
          --name $ETCD_NODENAME \
          --data-dir="${HOSTFS}/var/lib/etcd" \
          --initial-cluster-token etcd-${CLUSTERNAME} \
          --initial-advertise-peer-urls https://${ETCD_NODENAME}:2380 \
          --initial-cluster $ETCD_NODENAME=https://${ETCD_NODENAME}:2380
      fi
    fi
  fi

  # Delete old node certs in case they are around
  rm -f ${HOSTFS}/etc/kubernetes/pki/etcd/peer.* ${HOSTFS}/etc/kubernetes/pki/etcd/server.* ${HOSTFS}/etc/kubernetes/pki/etcd/healthcheck-client.* \
    ${HOSTFS}/etc/kubernetes/pki/apiserver* ${HOSTFS}/etc/kubernetes/pki/front-proxy-client.*

  # Issue all certs first, needed for eg. aws-iam-authenticator setup
  _kubeadm init phase certs all

  pre_kubeadm

  # Pull all images
  _kubeadm config images pull

  _kubeadm init phase preflight
  _kubeadm init phase kubeconfig all

  if [[ "$CMD" =~ ^(join)$ ]]; then
    # Delete any former self in case forseti did not delete yet
    kubectl delete node ${NODENAME} --wait=true || true
    # Wait for all pods to be deleted otherwise we end up with stale pods eg. kube-proxy and all goes to ....
    kubectl delete pods -n kube-system --field-selector spec.nodeName=${NODENAME}

    # get current running etcd pods for etcdctl commands
    while true; do
      etcd_endpoints=$(kubectl get pods -n kube-system -l component=etcd -o yaml | \
        yq eval '.items[].metadata.annotations."kubeadm.kubernetes.io/etcd.advertise-client-urls"' - | tr '\n' ',' | sed -e 's/,$//')
      [[ $etcd_endpoints =~ ^https:// ]] && break
      sleep 3
    done

    # see if we are a former member and remove our former self if so
    MY_ID=$(etcdctl member list --endpoints=$etcd_endpoints | grep $ETCD_NODENAME | awk '{print $1}' | sed -e 's/,$//')
    [ -n "$MY_ID" ] && retry 12 5 5 etcdctl member remove $MY_ID --endpoints=$etcd_endpoints

    # flush etcd data directory as joining with previous storage seems flaky, especially during etcd version upgrades
    rm -rf ${HOSTFS}/var/lib/etcd/member

    # Announce new etcd member and capture ETCD_INITIAL_CLUSTER, retry needed in case another node joining causes temp quorum loss
    ETCD_ENVS=$(retry 12 5 5 etcdctl member add $ETCD_NODENAME --peer-urls="https://${ETCD_NODENAME}:2380" --endpoints=$etcd_endpoints)
    export $(echo "$ETCD_ENVS" | grep ETCD_INITIAL_CLUSTER= | sed -e 's/"//g')

    # Patch kubeadm-values.yaml and re-render to get etcd manifest patched
    yq eval -i '.etcd.state = "existing"
      | .etcd.initialCluster = strenv(ETCD_INITIAL_CLUSTER)
      ' ${HOSTFS}/etc/kubernetes/kubeadm-values.yaml

    render_kubeadm $CMD
  fi

  # Generate our custom etcd yaml
  _kubeadm init phase etcd local
  _kubeadm init phase control-plane all

  _kubeadm init phase kubelet-start

  cp ${HOSTFS}/etc/kubernetes/super-admin.conf ${HOSTFS}/root/.kube/config

  # Wait for api to be online
  echo "Waiting for Kubernetes API to be online ..."
  retry 0 5 30 kubectl cluster-info --request-timeout 3 >/dev/null

  # Update providerID as underlying VM changed during restore
  if [[ "$CMD" =~ ^(restore)$ ]]; then
    if [ -n "$PROVIDER_ID" ]; then
      etcdhelper \
        -cacert ${HOSTFS}/etc/kubernetes/pki/etcd/ca.crt \
        -cert ${HOSTFS}/etc/kubernetes/pki/etcd/server.crt \
        -key ${HOSTFS}/etc/kubernetes/pki/etcd/server.key \
        -endpoint https://${ETCD_NODENAME}:2379 \
        change-provider-id ${NODENAME} $PROVIDER_ID
    fi
  fi

  _kubeadm init phase upload-config all

  if [[ "$CMD" =~ ^(bootstrap|restore)$ ]]; then
    # we share certs via the control plane backup
    #_kubeadm init phase upload-certs --skip-certificate-key-print

    # This sets up the ClusterRoleBindings to allow bootstrap nodes to create CSRs etc.
    _kubeadm init phase bootstrap-token --skip-token-print
  fi

  _kubeadm init phase mark-control-plane
  _kubeadm init phase kubelet-finalize all

  if [[ "$CMD" =~ ^(bootstrap|restore)$ ]]; then
    _kubeadm init phase addon all
  fi

  # Ensure aws-iam-authenticator secret is in place
  if [ "$AWS_IAM_AUTH" == "true" ]; then
    kubectl get secrets -n kube-system aws-iam-certs || \
    kubectl create secret generic aws-iam-certs -n kube-system \
      --from-file=key.pem=${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.key \
      --from-file=cert.pem=${HOSTFS}/etc/kubernetes/pki/aws-iam-authenticator.crt

    # Store aws-iam-auth admin on SSM
    yq eval -M ".clusters[0].cluster.certificate-authority-data = \"$(cat ${HOSTFS}/etc/kubernetes/pki/ca.crt | base64 -w0)\"" ${WORKDIR}/kubeadm/templates/admin-aws-iam.yaml > ${HOSTFS}/etc/kubernetes/admin-aws-iam.yaml
  fi

  post_kubeadm

  echo "${CMD}ed cluster $CLUSTERNAME successfully."
}


apply_module() {
  MODULES=$1

  get_kubezero_values $ARGOCD

  # Always use embedded kubezero chart
  helm template $CHARTS/kubezero -f $WORKDIR/kubezero-values.yaml --version ~$KUBE_VERSION --devel --output-dir $WORKDIR

  # CRDs first
  for t in $MODULES; do
    _helm crds $t
  done

  for t in $MODULES; do
    _helm apply $t
  done

  echo "Applied KubeZero modules: $MODULES"
}


delete_module() {
  MODULES=$1

  get_kubezero_values $ARGOCD

  # Always use embedded kubezero chart
  helm template $CHARTS/kubezero -f $WORKDIR/kubezero-values.yaml --version ~$KUBE_VERSION --devel --output-dir $WORKDIR

  for t in $MODULES; do
    _helm delete $t
  done

  echo "Deleted KubeZero modules: $MODULES. Potential CRDs must be removed manually."
}

# backup etcd + /etc/kubernetes/pki
backup() {
  # Display all ENVs, careful this exposes the password !
  [ -n "$DEBUG" ] && env

  restic snapshots || restic init || exit 1

  CV=$(kubectl version -o json | jq .serverVersion.minor -r)
  let PCV=$CV-1

  CLUSTER_VERSION="v1.$CV"
  PREVIOUS_VERSION="v1.$PCV"

  etcdctl --endpoints=https://${ETCD_NODENAME}:2379 snapshot save ${WORKDIR}/etcd_snapshot

  # pki & cluster-admin access
  cp -r ${HOSTFS}/etc/kubernetes/pki ${WORKDIR}
  cp ${HOSTFS}/etc/kubernetes/admin.conf ${WORKDIR}
  cp ${HOSTFS}/etc/kubernetes/super-admin.conf ${WORKDIR}

  # Backup via restic
  restic backup ${WORKDIR} -H $CLUSTERNAME --tag $CLUSTER_VERSION

  echo "Backup complete."

  # Remove backups from pre-previous versions
  restic forget --keep-tag $CLUSTER_VERSION --keep-tag $PREVIOUS_VERSION --prune

  # Regular retention
  restic forget --keep-hourly 24 --keep-daily ${RESTIC_RETENTION:-7} --prune

  # Defrag etcd backend
  etcdctl --endpoints=https://${ETCD_NODENAME}:2379 --command-timeout=60s defrag
}


debug_shell() {
  echo "Entering debug shell"

  printf "For manual etcdctl commands use:\n  # export ETCDCTL_ENDPOINTS=$ETCD_NODENAME:2379\n"

  /bin/bash
}

# First parse kubeadm-values.yaml
parse_kubezero

# Execute tasks
for t in $@; do
  case "$t" in
    bootstrap) control_plane_node bootstrap;;
    join) control_plane_node join;;
    restore) control_plane_node restore;;
    kubeadm_upgrade)
      ARGOCD=$(argo_used)
      kubeadm_upgrade;;
    apply_*)
      ARGOCD=$(argo_used)
      apply_module "${t##apply_}";;
    delete_*)
      ARGOCD=$(argo_used)
      delete_module "${t##delete_}";;
    backup) backup;;
    debug_shell) debug_shell;;
    *) echo "Unknown command: '$t'";;
  esac
done

