#!/bin/bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Recocncile a folder in the gitops repo

echo "----Reconcile $3 folder in the gitops repo $1 on $2 branch-----"

CONTROL_PLANE_URL=$1 # https://github.com/eedorenko/kalypso-oci-gitops
CONTROL_PLANE_BRANCH=$2 # dev
CONTROL_PLANE_FOLDER=$3 # vm

logfile=/opt/kalypso/log/$CONTROL_PLANE_BRANCH-$CONTROL_PLANE_FOLDER.log
errorfile=/opt/kalypso/log/$CONTROL_PLANE_BRANCH-$CONTROL_PLANE_FOLDER.err

ansible-pull -o --check --list-hosts -U $CONTROL_PLANE_URL -C $CONTROL_PLANE_BRANCH -d control-plane  > $logfile 2>$errorfile

if cat $logfile | grep -q "\"changed\": false"
then
  echo "No changes to apply"
  exit
fi

# itereate over all first level folders in control-plane sunbfolder and play them
for d in $(find control-plane/$CONTROL_PLANE_FOLDER -maxdepth 1 -mindepth 1 -type d)
do
  echo "Reconcile $d deployment target"
  pushd $d
  ansible-playbook -b namespace.yaml
  ansible-playbook -b reconciler.yaml
  processedDeploymentTargets+=($(basename "$d"))
  popd
done

# delete all created users that are not in processedDeploymentTargets array
for u in $(cut -d: -f1 /etc/passwd | grep $CONTROL_PLANE_BRANCH- | sed "s/^.*$CONTROL_PLANE_BRANCH-//")
do
 # if user is not in processedDeploymentTargets array
  if [[ ! " ${processedDeploymentTargets[@]} " =~ " ${u} " ]]; then
    deleteUser=$CONTROL_PLANE_BRANCH-$u
    echo "Delete user $deleteUser"
    sudo pkill -u $deleteUser
    sudo userdel -r -f $deleteUser
  fi 
done




