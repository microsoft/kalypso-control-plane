# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#!/bin/bash
echo $1

baserepo-template="baserepo-template.yaml"

set -euo pipefail
cat $baserepo-template | envsubst > $1

