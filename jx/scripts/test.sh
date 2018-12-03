#!/bin/bash

set -e
set -u
set -o pipefail
	
echo "PREVIEW_VERSION=$PREVIEW_VERSION"
echo "PREVIEW_NAMESPACE=$PREVIEW_NAMESPACE"
echo "HELM_RELEASE=$HELM_RELEASE"

helm3 --version

# kubectl create namespace $PREVIEW_NAMESPACE
# helm3 upgrade --install --namespace $PREVIEW_NAMESPACE
# check that the Job has completed
# kubectl delete namespace $PREVIEW_NAMESPACE


