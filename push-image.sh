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

if [[ "$GITHUB_REF" == refs/tags/* ]]; then
  RAW_TAG="${GITHUB_REF#refs/tags/}"
  IS_TAG=true
else
  RAW_BRANCH="${GITHUB_REF#refs/heads/}"
  TAG_NAME="${RAW_BRANCH//\//-}"
  IS_TAG=false
fi

if [[ "$IS_TAG" == true ]]; then
  echo "Building and pushing image with tag: $TAG_NAME"
  docker build -t $IMAGE_NAME:$TAG_NAME .
  docker push $IMAGE_NAME:$TAG_NAME
else
  echo "Building image with short SHA and branch name: $SHORT_SHA, $TAG_NAME"
  docker build -t $IMAGE_NAME:$SHORT_SHA -t $IMAGE_NAME:$TAG_NAME .
  if [[ "$TAG_NAME" == "master" || "$TAG_NAME" == "dev" ]]; then
    docker push $IMAGE_NAME:$SHORT_SHA
  fi
  docker push $IMAGE_NAME:$TAG_NAME

  if [[ "$TAG_NAME" == "master" ]]; then
    docker tag $IMAGE_NAME:$SHORT_SHA $IMAGE_NAME:latest
    docker push $IMAGE_NAME:latest
  fi
fi
