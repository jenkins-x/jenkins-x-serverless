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

declare -a arr=(csharp cwp elixir go gradle javascript jenkins maven-java11 maven python ruby rust scala)

ORG=$1
TAG=$2

## now loop through the above array
for i in "${arr[@]}"
do
    echo "Building jenkins-${i}"
	sed -i.bak -e "s/FROM .*/FROM ${ORG}\/jenkins-base:${TAG}/" Dockerfile.${i}
	rm Dockerfile.$i.bak
done

# if [ "release" == "${RELEASE}" ]; then
#   updatebot push-regex -r "jenkinsTag: (.*)" -v ${TAG} jx-build-templates/values.yaml
# fi