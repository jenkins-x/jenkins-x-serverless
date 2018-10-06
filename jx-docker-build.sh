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

echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG}"
docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG} -f Dockerfile.filerunner . > /dev/null
head -n 1 Dockerfile.base
echo "Built ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG}"

sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-filerunner:${TAG}/" Dockerfile.base
rm Dockerfile.base.bak
head -n 1 Dockerfile.base
echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"
docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG} -f Dockerfile.base .
echo "Built ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"

declare -a arr=("maven" "javascript" "go" "gradle" "python" "scala" "rust" "csharp" "jenkins" "cwp")

## now loop through the above array
for i in "${arr[@]}"
do
    echo "building builder-$i"
	sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-base:${TAG}/" Dockerfile.$i
	rm Dockerfile.$i.bak
	head -n 1 Dockerfile.$i
	echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-$i:${TAG}"
    docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-$i:${TAG} -f Dockerfile.$i .
done

if [ "release" == "${RELEASE}" ]; then
    jx step tag --version $TAG_NUM
fi

# run the tests against the maven release
if [ "pr" == "${RELEASE}" ]; then
	echo "Running test pack..."
    #jx create post preview job --name owasp --image owasp/zap2docker-stable:latest -c "zap-baseline.py" -c "-t" -c "\$(JX_PREVIEW_URL)" 
	#docker run --rm \
    #    -v $PWD/Jenkinsfile-test:/workspace/Jenkinsfile \
    #    -v /var/run:/var/run \
    #    -v /etc/resolv.conf:/etc/resolv.conf \
	#	$ORG/jenkins-maven:$TAG
	#-e DOCKER_CONFIG=$DOCKER_CONFIG \
	#-e DOCKER_REGISTRY=$DOCKER_REGISTRY \
fi

if [ "release" == "${RELEASE}" ]; then
	for i in "${arr[@]}"
	do
   		echo "pushing builder-$i to ${DOCKER_REGISTRY}"
   		docker push ${DOCKER_REGISTRY}/$ORG/jenkins-$i:$TAG
	done
fi
