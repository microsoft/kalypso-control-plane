# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Temporary mannifest generation script. For demo purposes only.
# Will be replaced with a permanent approach

#!/bin/bash

set -eo pipefail  # fail on error

WORKLOAD=$1
TEMPLATE=$2

WORKLOAD_NAME=$(yq '.metadata.name' $WORKLOAD)
WORKLOAD_WORKSPACE=$(yq '.spec.workspace' $WORKLOAD)

WORKLOAD_REPO=$(yq '.spec.workload.repo' $WORKLOAD)
WORKLOAD_BRANCH=$(yq '.spec.workload.branch' $WORKLOAD)
WORKLOAD_PATH=$(yq '.spec.workload.path' $WORKLOAD)

gh auth login --with-token <<<"$TOKEN"
echo $WORKLOAD_REPO
git clone $WORKLOAD_REPO --depth 1 --branch $WORKLOAD_BRANCH workload

export DEPLOYMENT_TARGET_REPO=$(yq '.spec.deploymentTargets[0].manifests.repo' workload/$WORKLOAD_PATH)
export DEPLOYMENT_TARGET_BRANCH=$(yq '.spec.deploymentTargets[0].manifests.branch' workload/$WORKLOAD_PATH)
export DEPLOYMENT_TARGET_PATH=$(yq '.spec.deploymentTargets[0].manifests.path' workload/$WORKLOAD_PATH)

export DEPLOYMENT_TARGET_NAME=$(yq '.spec.deploymentTargets[0].name' workload/$WORKLOAD_PATH)
export DEPLOYMENT_TARGET_ENVIRONMENT=$(yq '.spec.deploymentTargets[0].environment' workload/$WORKLOAD_PATH)
export DEPLOYMENT_TARGET_NAMESPACE=$DEPLOYMENT_TARGET_ENVIRONMENT-$WORKLOAD_WORKSPACE-$WORKLOAD_NAME-$DEPLOYMENT_TARGET_NAME

echo $DEPLOYMENT_TARGET_NAMESPACE

cat $TEMPLATE | sed -r 's/[{{]+/$/g' | sed 's/}}//g' | envsubst
