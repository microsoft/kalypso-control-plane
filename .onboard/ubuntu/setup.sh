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

kalypso_home=/opt/kalypso

mkdir -p $kalypso_home/log

curl -fsSL -o $kalypso_home/onboard.sh https://raw.githubusercontent.com/microsoft/kalypso-control-plane/eedorenko/ansible/.onboard/ubuntu/onboard.sh
curl -fsSL -o $kalypso_home/install-deb-package.yml https://raw.githubusercontent.com/microsoft/kalypso-control-plane/eedorenko/ansible/.onboard/ubuntu/install-deb-package.yml
curl -fsSL -o $kalypso_home/onboard.yml https://raw.githubusercontent.com/microsoft/kalypso-control-plane/eedorenko/ansible/.onboard/ubuntu/onboard.yml
curl -fsSL -o $kalypso_home/reconcile.sh https://raw.githubusercontent.com/microsoft/kalypso-control-plane/eedorenko/ansible/.onboard/ubuntu/reconcile.sh

