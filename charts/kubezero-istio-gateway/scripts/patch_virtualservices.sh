#!/bin/bash -x

# Get all public vs
for vs in $(kubectl get vs -A | grep "istio-system/ingressgateway" | awk '{print $1 ":" $2}'); do
  ns=${vs%%:*}
  name=${vs##*:}

  kubectl patch virtualservice $name -n $ns --type=json \
  -p='[{"op": "replace", "path": "/spec/gateways/0", "value":"istio-ingress/ingressgateway"}]'
done

# Get all private vs
for vs in $(kubectl get vs -A | grep "istio-system/private-ingressgateway" | awk '{print $1 ":" $2}'); do
  ns=${vs%%:*}
  name=${vs##*:}

  kubectl patch virtualservice $name -n $ns --type=json \
  -p='[{"op": "replace", "path": "/spec/gateways/0", "value":"istio-ingress/private-ingressgateway"}]'
done
