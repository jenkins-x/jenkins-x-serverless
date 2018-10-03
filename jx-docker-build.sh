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
TAG=dev_$TAG_NUM

docker build -t $ORG/jenkins-filerunner:$TAG -f Dockerfile-filerunner .
head -n 1 Dockerfile-base
echo "Built $ORG/jenkins-filerunner:$TAG"

sed -i -e "s/FROM .*/FROM ${ORG}\/jenkins-filerunner:${TAG}/" Dockerfile-base
head -n 1 Dockerfile-base
docker build -t $ORG/jenkins-base:$TAG -f Dockerfile-base .
echo "Built $ORG/jenkins-base:$TAG"

#declare -a arr=("maven" "javascript" "go" "gradle" "python" "scala" "rust" "csharp" "jenkins" "cwp")
declare -a arr=("maven")

## now loop through the above array
for i in "${arr[@]}"
do
    echo "building builder-$i"
	sed -i -e "s/FROM .*/FROM ${ORG}\/jenkins-base:${TAG}/" Dockerfile-$i
	head -n 1 Dockerfile-$i
    docker build -t $ORG/jenkins-$i:$TAG -f Dockerfile-$i .
done

if [ "release" == "${RELEASE}" ]; then
    jx step tag --version $TAG_NUM
fi

echo "============================= debug ========================="
ls -la /var/run/docker.sock
ls -la /var/run/secrets/kubernetes.io/serviceaccount/token

# run the tests against the maven release
if [ "pr" == "${RELEASE}" ]; then
	docker run --rm \
		-e DOCKER_CONFIG=$DOCKER_CONFIG \
		-e DOCKER_REGISTRY=$DOCKER_REGISTRY \
        -v $PWD/Jenkinsfile-test:/workspace/Jenkinsfile \
        -v /var/run/:/var/run/ \
		$ORG/jenkins-maven:$TAG
fi

export DOCKER_REGISTRY=docker.io

for i in "${arr[@]}"
do
	if [ "release" == "${RELEASE}" ]; then
    	echo "pushing builder-$i"
    	docker push $ORG/jenkins-$i:$TAG
	fi
done
