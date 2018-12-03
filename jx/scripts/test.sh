#!/bin/bash

set -e
set -u
set -o pipefail
	
echo "PREVIEW_VERSION=$PREVIEW_VERSION"
echo "PREVIEW_NAMESPACE=$PREVIEW_NAMESPACE"
echo "HELM_RELEASE=$HELM_RELEASE"

pushd jenkins-x-serverless
	make build  

	kubectl create namespace $PREVIEW_NAMESPACE
    jx ns $PREVIEW_NAMESPACE
	helm3 upgrade --name jenkins-x-serverless . --install --namespace $PREVIEW_NAMESPACE
	# check that the Job has completed
    kubectl get pods
	kubectl delete namespace $PREVIEW_NAMESPACE
popd



