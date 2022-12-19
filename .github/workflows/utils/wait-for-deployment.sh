#!/bin/bash

while getopts "r:b:c:" option;
    do
    case "$option" in
        r ) REPO_URL=${OPTARG};;
        b ) REPO_BRANCH=${OPTARG};;
        c ) COMMIT_ID=${OPTARG};;
    esac
done

total_attempts=60
set -eo pipefail  # fail on error
az extension add --name resource-graph

error() {
   echo $1>&2
   exit 1
}

usage() {
echo $1>&2    
cat <<EOM
Usage:
  wait_for_deployment.sh flags

Flags:
  -r       GitOps Repository URL (e.g. https://github.com/microsoft/kalypso-gitops)
  -b       Environment branch (e.g. dev)
  -c       Commit Id  (e.g. c32f8da476689f8cf309ca0e3fbbda42b3a8d387)

Example:
  wait_for_deployment.sh -r https://github.com/microsoft/kalypso-gitops -b dev -c c32f8da476689f8cf309ca0e3fbbda42b3a8d387
EOM
exit 1
}

check_parameters() {
    if [ -z $REPO_URL ] && [ -z $REPO_BRANCH ] && [ -z $COMMIT_ID ]
    then
        usage "No arguments specified"
    elif [ -z $REPO_URL ]
    then
        usage "No repository url specified"  
    elif [ -z $REPO_BRANCH ]
    then
        usage "No repository branch specified"  
    elif [ -z $COMMIT_ID ]
    then
        usage "No commit ID specified"  
    fi
}

get_all_configs() {
    total_query="kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | where properties.gitRepository.url == ""'""$REPO_URL""'"" | where properties.gitRepository.repositoryRef.branch == ""'""$REPO_BRANCH""'"""
    az graph query -q "$total_query"
}

get_synched_configs() {
    complianceState=$1
    sycnhed_query="kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | where properties.sourceSyncedCommitId == ""'""$REPO_BRANCH/$COMMIT_ID""'"" | where properties.complianceState == ""'""$complianceState""'"""
    az graph query -q "$sycnhed_query"
}


wait_for_deployment() {
attempt=1
while [ $attempt -lt $total_attempts ]
do
    echo "Check Deployment Attempt $attempt ..."
    
    total_configs=$( get_all_configs | jq '.total_records')
    
    echo "There are $total_configs refernceing confgigurations"        

    if (( $total_configs > 0 ));
    then      
      echo "Checking for non-compliant configurations ..."
      non_compliant_configs=$(get_synched_configs 'Non-Compliant')
      echo $non_compliant_configs
      total_non_compliant_configs=$( echo $non_compliant_configs | jq '.total_records')

      if (( $total_non_compliant_configs > 0 ));
      then
        error "There are $total_non_compliant_configs Non_Compliant configurations:  " + $non_compliant_configs
      fi

      echo "Checking for compliant configurations ..."
      compliant_configs=$(get_synched_configs 'Compliant')
      echo $compliant_configs
      total_compliant_configs=$( echo $compliant_configs | jq '.total_records')

      if (( $total_compliant_configs == $total_configs ));
      then
        echo "All $total_configs configurations are compliant "        
        exit 0
      else
       echo "$total_compliant_configs out of $total_configs configurations are compliant. Keep polling... "
      fi

      sleep 5
      attempt=$(( $attempt + 1 ))
    else
      exit 0
    fi    

done

error "$total_compliant_configs out of $total_configs configurations are compliant. Deployment is failed "


}

check_parameters
wait_for_deployment


