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
	helm3 upgrade --name jenkins-x-serverless . --install --namespace $PREVIEW_NAMESPACE
	# check that the Job has completed
    kubectl get pods
	kubectl delete namespace $PREVIEW_NAMESPACE
popd



