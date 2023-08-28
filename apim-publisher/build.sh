#!/usr/bin/env bash

APIM_IMAGE_REPO=gcacrapim.azurecr.io/apim-publisher

version_file_path="$(dirname -- ${BASH_SOURCE[0]})/APIM_VERSION"
APIM_VERSION=$(cat $version_file_path)
VERSION=$(echo $APIM_VERSION | sed -e 's/^v//')
VERSION="${VERSION}-5"

docker build --platform linux/amd64 \
  --build-arg APIM_VERSION=$APIM_VERSION \
  -t $APIM_IMAGE_REPO:$VERSION .

az acr login --name gcacrapim

docker push $APIM_IMAGE_REPO:$VERSION
docker tag $APIM_IMAGE_REPO:$VERSION $APIM_IMAGE_REPO:latest
docker push $APIM_IMAGE_REPO:latest

# example
# docker build --platform linux/amd64 --build-arg APIM_VERSION=v4.9.0 -t gcacrapim.azurecr.io/apim-publisher:4.9.0-4 .
# docker push gcacrapim.azurecr.io/apim-publisher:4.9.0-4