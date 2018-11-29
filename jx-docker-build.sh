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

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run
retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1

    until $cmd
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}

TAG_NUM=$1
ORG=$2
RELEASE=$3
TAG=$TAG_NUM

export DOCKER_REGISTRY=docker.io

echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG}"
retry 10 docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG} -f Dockerfile.filerunner .
head -n 1 Dockerfile.filerunner
echo "Built ${DOCKER_REGISTRY}/${ORG}/jenkins-filerunner:${TAG}"

sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-filerunner:${TAG}/" Dockerfile.base
rm Dockerfile.base.bak
head -n 1 Dockerfile.base
echo "Building ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"
retry 10 docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG} -f Dockerfile.base .
echo "Built ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}"

# always push
echo "pushing jenkins-base to ${DOCKER_REGISTRY}"
retry 10 docker push ${DOCKER_REGISTRY}/${ORG}/jenkins-base:${TAG}

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
   	retry 10 docker build -t ${DOCKER_REGISTRY}/${ORG}/jenkins-${i}:${TAG} -f Dockerfile.${i} .
    # always push
	echo "pushing jenkins-${i} to ${DOCKER_REGISTRY}"
   	retry 10 docker push ${DOCKER_REGISTRY}/${ORG}/jenkins-${i}:${TAG}
done

if [ "pr" == "${RELEASE}" ]; then
    pushd jenkins-x-serverless
		sed -i.bak -e "s/tag: .*/tag: ${TAG}/" values.yaml
		rm values.yaml.bak
        cat values.yaml
   		make build
	popd
fi

if [ "release" == "${RELEASE}" ]; then
  updatebot push-regex -r "jenkinsTag: (.*)" -v ${TAG} jx-build-templates/values.yaml
fi
