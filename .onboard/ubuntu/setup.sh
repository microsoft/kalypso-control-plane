# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#!/bin/bash
set -eo pipefail

check_prerequisites() {  
  type -p ansible >/dev/null
  type -p git >/dev/null
  type -p yq >/dev/null
  type -p curl >/dev/null
}

print_prerequisites() {
  echo "The following tools are required to run this script:"
  echo " - ansible"
  echo " - git"
  echo " - yq"
  echo " - curl"
  exit 1
}

check_prerequisites || print_prerequisites

mkdir -p /opt/kalypso1/log

curl -fsSL -o /opt/kalypso1/ https://raw.githubusercontent.com/microsoft/kalypso-control-plane/eedorenko/ansible/.onboard/ubutu/

## Install ansible
## copy files

# sudo apt-add-repository -y ppa:ansible/ansible
# sudo apt-get update
# sudo apt-get install -y ansible

# install yq

# upddate /etc/ansible/hosts with

# mkdir -p /opt/kalypso/log

# [local]
# 127.0.0.1

# [all:vars]
# ansible_user=test
# ansible_ssh_pass=test

# ansible all -m ping

# ansible-pull -o -U https://github.com/eedorenko/kalypso-oci-gitops -C dev -d vm | logger -p local4.debug

#         # ./opt/kalypso/reconcile.sh {{repo_url}} {{repo_branch}} {{repo_folder}}  >> /opt/kalypso/log/gitops-{{repo_branch}}-{{repo_folder}}.log 2>>&1
#         job: "./opt/kalypso/reconcile.sh {{repo_url}} {{repo_branch}} {{repo_folder}} > /opt/kalypso/log/gitops-{{repo_branch}}-{{repo_folder}}.log 2>&1"