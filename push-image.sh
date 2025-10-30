#!/bin/bash

# This script is intended to be run exclusively in GitHub Actions workflows.
# It builds and pushes Docker images to a container registry based on the
# current branch or tag ref from the GitHub event environment variables.
# Usage: ./deploy.sh <image_name>
#
# Environment variables required:
# - GITHUB_SHA: Commit SHA of the current GitHub event.
# - GITHUB_REF: Git ref (branch or tag) of the current GitHub event.

set -e

IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]; then
  echo "Usage: $0 <image_name>"
  exit 1
fi

SHORT_SHA=${GITHUB_SHA::7}
BRANCH_NAME=${GITHUB_REF#refs/heads/}
TAG_NAME=${GITHUB_REF#refs/tags/}

if [[ -n "$TAG_NAME" ]]; then
  echo "Building and pushing image with tag: $TAG_NAME"
  docker build -t $IMAGE_NAME:$TAG_NAME .
  docker push $IMAGE_NAME:$TAG_NAME
else
  echo "Building image with short SHA and branch name: $SHORT_SHA, $BRANCH_NAME"
  docker build -t $IMAGE_NAME:$SHORT_SHA -t $IMAGE_NAME:$BRANCH_NAME .
  if [[ "$BRANCH_NAME" == "master" || "$BRANCH_NAME" == "dev" ]]; then
    docker push $IMAGE_NAME:$SHORT_SHA
  fi
  docker push $IMAGE_NAME:$BRANCH_NAME

  if [[ "$BRANCH_NAME" == "master" ]]; then
    docker tag $IMAGE_NAME:$SHORT_SHA $IMAGE_NAME:latest
    docker push $IMAGE_NAME:latest
  fi
fi
