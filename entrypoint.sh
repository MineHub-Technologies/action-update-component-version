#!/bin/bash

set -e -o nounset -o pipefail

# Setup SSH KEY
mkdir --parents "${HOME}/.ssh"
DEPLOY_KEY_FILE="${HOME}/.ssh/deploy_key"
echo "${INPUT_DEPLOY_KEY}" > "${DEPLOY_KEY_FILE}"
chmod 600 "${DEPLOY_KEY_FILE}"

SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
ssh-keyscan -H "github.com" > "${SSH_KNOWN_HOSTS_FILE}"
export GIT_SSH_COMMAND="ssh -i "${DEPLOY_KEY_FILE}" -o UserKnownHostsFile=${SSH_KNOWN_HOSTS_FILE}"

CLONE_DIR=$(mktemp -d)

cd "${GITHUB_WORKSPACE}" || exit

## Setup git
git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"

git clone --branch "${INPUT_DESTINATION_BRANCH}" "git@github.com:${INPUT_DESTINATION_REPO}.git"

cd mh-kubernetes-resources/minehub/applications/mongo

yq --yaml-output \
   --arg version "1.1.1" \
    '.spec.source.helm.parameters[0].value |= $version' \
    "mongo.yaml" | sponge "mongo.yaml"

git status
