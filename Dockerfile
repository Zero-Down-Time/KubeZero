ARG ALPINE_VERSION=3.20

FROM docker.io/alpine:${ALPINE_VERSION}

ARG ALPINE_VERSION
ARG KUBE_VERSION=1.30.5
ARG SECRETS_VERSION=4.6.1
ARG VALS_VERSION=0.37.5

RUN cd /etc/apk/keys && \
    wget "https://cdn.zero-downtime.net/alpine/stefan@zero-downtime.net-61bb6bfb.rsa.pub" && \
    echo "@kubezero https://cdn.zero-downtime.net/alpine/v${ALPINE_VERSION}/kubezero" >> /etc/apk/repositories && \
    echo "@edge-testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk upgrade -U -a --no-cache && \
    apk --no-cache add \
      jq \
      yq \
      diffutils \
      bash \
      python3 \
      py3-yaml \
      restic \
      helm \
      etcd-ctl@edge-community \
      cri-tools@kubezero \
      etcdhelper@kubezero \
      kubeadm@kubezero~=${KUBE_VERSION} \
      kubectl@kubezero~=${KUBE_VERSION}

RUN helm repo add kubezero https://cdn.zero-downtime.net/charts && \
    mkdir -p /var/lib/kubezero

# helm secrets
RUN mkdir -p $(helm env HELM_PLUGINS) && \
    wget -qO - https://github.com/jkroepke/helm-secrets/releases/download/v${SECRETS_VERSION}/helm-secrets.tar.gz | tar -C "$(helm env HELM_PLUGINS)" -xzf-

# vals
RUN wget -qO - https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz | tar -C /usr/local/bin -xzf- vals

ADD admin/kubezero.sh admin/libhelm.sh admin/migrate_argo_values.py /usr/bin
ADD admin/libhelm.sh /var/lib/kubezero

ADD charts/kubeadm /charts/kubeadm
ADD charts/kubezero /charts/kubezero

ENTRYPOINT ["kubezero.sh"]
