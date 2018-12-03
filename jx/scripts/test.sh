#!/bin/bash

set -e
set -u
set -o pipefail
	
echo "PREVIEW_VERSION=$PREVIEW_VERSION"
echo "PREVIEW_NAMESPACE=$PREVIEW_NAMESPACE"
echo "HELM_RELEASE=$HELM_RELEASE"

pushd jenkins-x-serverless
	make build  

	if [[ $(kubectl get namespace ${PREVIEW_NAMESPACE} | grep -c "${PREVIEW_NAMESPACE}") -eq 1 ]]; then
		echo "$PREVIEW_NAMESPACE already exists"	
	else 
		kubectl create namespace $PREVIEW_NAMESPACE
	fi 

    jx ns $PREVIEW_NAMESPACE

	helm3 upgrade \
		--set serverless.nameOverride=$HELM_RELEASE \ 
		--install --namespace $PREVIEW_NAMESPACE \
		$HELM_RELEASE .

	# check that the Job has completed

	SUCCESS=false
	TIME_BETWEEN_CHECKS=10
	COUNTER=0

    while [  $COUNTER -lt 20 ]; do
        echo "Checking attempt $COUNTER..."
    	POD_STATUS=`kubectl get pods | grep $HELM_RELEASE | awk '{print $3}'`
        
    	if [ ${POD_STATUS} == "Completed" ]; then
			SUCCESS=true
			echo "Pod completed correctly"
			break
		fi
    	
		if [ ${POD_STATUS} == "Error" ]; then
			echo "Pod is in error status"
			break
		fi

		let COUNTER=COUNTER+1 
		sleep ${TIME_BETWEEN_CHECKS}
    done

	# cleanup	
	helm3 del $HELM_RELEASE --purge
	kubectl delete namespace $PREVIEW_NAMESPACE
	
	if [ "${SUCCESS}" == "false" ]; then
		echo "Pod never became ready"
		exit 1
	fi
popd



