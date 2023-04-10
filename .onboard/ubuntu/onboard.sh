#!/bin/bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Start watching a folder in gitops repo

echo "Start watching folder $3 in gitops repo $1 on $2 branch"

set -euo pipefail

CONTROL_PLANE_URL=$1 # https://github.com/eedorenko/kalypso-oci-gitops
CONTROL_PLANE_BRANCH=$2 # dev
CONTROL_PLANE_FOLDER=$3 # vm

print_usage() {
    printf "Usage: ./opt/kalypso/onboard.sh <gitops repo> <branch> <folder> \n"
    printf "\nExample ./opt/kalypso/onboard.sh https://github.com/eedorenko/kalypso-oci-gitops dev vm \n"                                                              
    exit 1
}


if [ -z $CONTROL_PLANE_URL ] || [ -z $CONTROL_PLANE_BRANCH ] || [ -z $CONTROL_PLANE_FOLDER ];
then
 print_usage
fi


ansible-playbook -b /opt/kalypso/onboard.yml -e "repo_url=$CONTROL_PLANE_URL" -e "repo_branch=$CONTROL_PLANE_BRANCH" -e "repo_folder=$CONTROL_PLANE_FOLDER"


