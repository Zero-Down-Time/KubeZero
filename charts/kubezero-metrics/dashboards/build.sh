#!/bin/bash

[ -x ./jb-linux-amd64 ] || wget https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.4.0/jb-linux-amd64 && chmod +x ./jb-linux-amd64

./jb-linux-amd64 update

mkdir -p kube-mixin
jsonnet -J vendor -m kube-mixin -e '(import "mixin.libsonnet").grafanaDashboards'
