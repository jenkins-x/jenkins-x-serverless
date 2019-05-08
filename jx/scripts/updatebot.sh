#!/bin/bash

set -e
set -u
set -o pipefail

echo "VERSION=$VERSION"

updatebot push-regex -r "jenkinsTag:\s(.*)" -v ${VERSION} jx-build-templates/values.yaml

