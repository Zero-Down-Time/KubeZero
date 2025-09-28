#!/bin/bash

NODES=$(kubectl get nodes -o json | jq -rc .items[].status.addresses[0].address)

for n in $NODES; do
  >&2 echo "Node: $n"
  ssh -q alpine@$n "$@"
done
