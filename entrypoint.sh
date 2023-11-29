#!/bin/bash

set -e -o nounset -o pipefail

cd "${GITHUB_WORKSPACE}" || exit

# Setup git
git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"

getOrganizations() {
  if $INPUT_ORGANIZATIONS; then
    echo "${INPUT_ORGANIZATIONS}"
    return
  fi
  set -e

  local listOfOrganizations
  listOfOrganizations=$(ls "./" | grep -v 'idp\|README.md\|.gitignore')

  echo "${listOfOrganizations}"
}

organizations=$(getOrganizations)
component_array=(${INPUT_COMPONENT_NAME})
for organization in $organizations; do
  echo $organization
  component_does_not_exist=true

  for component in "${component_array[@]}"; do
      if [ ! -d "${organization}/applications/${component}" ]; then
        echo "========== ${organization} ${component} does not exist =========="
      else
          component_does_not_exist=false
      fi
  done

  if [ "${component_does_not_exist}" = true ]; then
    echo "========== ${organization} does not have any component of ${INPUT_COMPONENT_NAME} =========="
    continue
  fi


  for component in "${component_array[@]}"; do

    if [ ! -d "${organization}/applications/${component}" ]; then
    pushd "${organization}/applications/${component}"

    yq --yaml-output \
       --arg version "${INPUT_VERSION}" \
        '(.spec.source.helm.parameters[] | select (.name == "image.tag") | .value) = $version'\
        "${component}.yaml" | sponge "${component}.yaml"

    echo "========== Updated ${organization} ${component} YAML =========="
    cat ${component}.yaml
    echo "========== Updated YAML =========="

    popd
  done
done
