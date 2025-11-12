#!/bin/bash

# read token
GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN)

function gh_get() {
  curl -s \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: fbox826/parser" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$1"
}

TARGET_REPO=${TARGET_REPO:-"stashapp/stash"}
WORKFLOW_NAME=${WORKFLOW_NAME:-"Build"}
ARTIFACT_NAME=${ARTIFACT_NAME:-"stash-linux"}

RUNS_JSON=$(gh_get "https://api.github.com/repos/${TARGET_REPO}/actions/runs?branch=${TARGET_BRANCH}&status=completed")
ARTIFACTS_URL=$(echo "${RUNS_JSON}" | jq -r ".workflow_runs | map(select(.name == \"${WORKFLOW_NAME}\")) | first | .artifacts_url ")
TARGET_ARTIFACT_URL=$(gh_get "${ARTIFACTS_URL}" | jq -r ".artifacts[] | select(.name == \"${ARTIFACT_NAME}\") | .archive_download_url")
curl -L \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${TARGET_ARTIFACT_URL}" -o "${ARTIFACT_NAME}.zip"
