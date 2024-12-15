#!/bin/bash
set -ex

. ../../scripts/lib-update.sh

login_ecr_public
update_helm

update_docs
