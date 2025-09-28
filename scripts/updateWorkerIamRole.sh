#!/bin/bash -ex

# Meant for testing only !!!

# This updates the proxy IAM role with the actual worker ASGs IAM roles 
# Make sure your AWS Profile points to right account

REGION="$1"
CLUSTER="$2"

TMPDIR=$(mktemp -p /tmp -d kubezero.XXX)
trap 'rm -rf $TMPDIR' ERR EXIT

# Get orig policy
aws iam get-role --output json --role-name $REGION-$CLUSTER-kube-workers | jq -c .Role.AssumeRolePolicyDocument > $TMPDIR/orig

# Add current and new list of entities to include
cat $TMPDIR/orig | jq -c .Statement[].Principal.AWS[] | sort | uniq > $TMPDIR/current-roles
aws iam list-roles --output json --path-prefix /$REGION/$CLUSTER/nodes/ | jq -c .Roles[].Arn | sort | uniq > $TMPDIR/new-roles

# If no diff exit
diff -tub $TMPDIR/current-roles $TMPDIR/new-roles && exit 0

# Create new policy
jq -c '.Statement[].Principal.AWS = $roles' $TMPDIR/orig --slurpfile roles $TMPDIR/new-roles > $TMPDIR/new
aws iam update-assume-role-policy --role-name $REGION-$CLUSTER-kube-workers --policy-document "$(cat $TMPDIR/new)"
