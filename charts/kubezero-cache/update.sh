#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

#login_ecr_public
update_helm

patch_chart redis
patch_chart redis-replication
patch_chart redis-sentinel
patch_chart redis-cluster

update_docs
