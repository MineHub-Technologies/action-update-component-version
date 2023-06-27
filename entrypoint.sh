#!/bin/bash

set -e -o nounset -o pipefail

cd "${GITHUB_WORKSPACE}" || exit

# Setup git
git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"

getOrganizations() {
  set -e

  local listOfOrganizations
  listOfOrganizations=$(ls "./" | grep -v 'idp\|README.md\|.gitignore')

  echo "${listOfOrganizations}"
}

organizations=$(getOrganizations)

for organization in $organizations; do
  echo $organization

  if [ ! -d "${organization}/applications/${INPUT_COMPONENT_NAME}" ]; then
    echo "========== ${organization} ${INPUT_COMPONENT_NAME} does not exist =========="
    continue
  fi

  pushd "${organization}/applications/${INPUT_COMPONENT_NAME}"

  yq --yaml-output \
     --arg version "${INPUT_VERSION}" \
      '(.spec.source.helm.parameters[] | select (.name == "image.tag") | .value) = $version'\
      "${INPUT_COMPONENT_NAME}.yaml" | sponge "${INPUT_COMPONENT_NAME}.yaml"

  echo "========== Updated ${organization} ${INPUT_COMPONENT_NAME} YAML =========="
  cat ${INPUT_COMPONENT_NAME}.yaml
  echo "========== Updated YAML =========="

  popd
done
