#!/bin/bash

set -e
set -u
set -o pipefail

echo "VERSION=$VERSION"

jx step create pr regex --regex "jenkinsTag:\s(.*)" --version ${VERSION} --files jx-build-templates/values.yaml --repo https://github.com/jenkins-x-charts/jx-build-templates.git
