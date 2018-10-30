#!/usr/bin/env bash
# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

TAG_NUM=$1
ORG=$2
RELEASE=$3
TAG=$TAG_NUM

export DOCKER_REGISTRY=docker.io

export JENKINSFILE_RUNNER_TAG="${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG}"
echo "Building ${JENKINSFILE_RUNNER_TAG}"
make clean build
echo "Built ${JENKINSFILE_RUNNER_TAG}"

sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-filerunner:${TAG}/" Dockerfile.base
rm Dockerfile.base.bak
head -n 1 Dockerfile.base
echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"
docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG} -f Dockerfile.base .
echo "Built ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"
if [ "release" == "${RELEASE}" ]; then
	echo "pushing jenkins-base to ${DOCKER_REGISTRY}"
   	docker push ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}
fi

declare -a arr=("maven" "javascript" "go" "gradle" "python" "scala" "rust" "csharp" "jenkins" "cwp")

## now loop through the above array
for i in "${arr[@]}"
do
    echo "building jenkins-${i}"
	sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-base:${TAG}/" Dockerfile.${i}
	rm Dockerfile.$i.bak
	head -n 1 Dockerfile.${i}
done


if [ "release" == "${RELEASE}" ]; then
    jx step tag --version $TAG_NUM
fi

for i in "${arr[@]}"
do
	echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-${i}:${TAG}"
   	docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-${i}:${TAG} -f Dockerfile.${i} .
	if [ "release" == "${RELEASE}" ]; then
   		echo "pushing jenkins-${i} to ${DOCKER_REGISTRY}"
   		docker push ${DOCKER_REGISTRY}/${ORG}/jenkins-${i}:${TAG}
	fi
done

if [ "release" == "${RELEASE}" ]; then
  updatebot push-regex -r "jenkinsTag: (.*)" -v ${TAG} jx-build-templates/values.yaml
fi
