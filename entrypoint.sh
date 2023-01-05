#!/bin/bash

set -e -o nounset -o pipefail

cd "${GITHUB_WORKSPACE}" || exit

# Setup git
git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"

cd "${INPUT_COMPONENT_FOLDER}"

yq --yaml-output \
   --arg version "${INPUT_VERSION}" \
    '.spec.source.helm.parameters[0].value |= $version' \
    "mongo.yaml" | sponge "mongo.yaml"

echo "========== Updated YAML =========="
cat mongo.yaml
echo "========== Updated YAML =========="
