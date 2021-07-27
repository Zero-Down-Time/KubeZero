#!/bin/bash
set -o pipefail

# Meant for testing only !!!

# This sets the Kubernetes Version in SSM
# Make sure your AWS Profile and Region points to the right direction ...

CONGLOMERATE=$1
VERSION=$2

P="/cloudbender/${CONGLOMERATE}/kubecontrol/meta/clusterversion"

export AWS_DEFAULT_OUTPUT=text

# First verify we point to an existing clusterVersion
OLD=$(aws ssm get-parameter --name $P --with-decryption --query 'Parameter.Value' | base64 -d) || \
  { echo "Cannot find an existing SSM parameter. Make sure your AWS profile and parameters are correct."; exit 1; }

echo "Current version: $OLD"
aws ssm put-parameter --name $P --type SecureString --value "$(echo "$VERSION" | base64 -w0)" --overwrite
echo "New version: $VERSION"
