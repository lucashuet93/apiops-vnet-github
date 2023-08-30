#!/usr/bin/env bash

VERSION=0.0.6-52
#VERSION=2.0.1-47
#VERSION=2.0.1-47
#VERSION=2.0.1-47

MAJOR_VERSION=${VERSION%.*.*}

ENV_NAME=dev

helm -n apim-be-${ENV_NAME} upgrade --install apim-demo-app oci://gcacrapim.azurecr.io/charts/apim-demo-app \
  -f ${ENV_NAME}.yaml \
  --set-file apim.apiInformation=../apimartifacts/apis/apim-be-${ENV_NAME}/apiInformation.json \
  --set-file apim.openApiSpec=../.apispecs/apim-demo-app.v${MAJOR_VERSION}.yaml \
  --set-file apim.policy=../apimartifacts/apis/apim-be-dev/policy.xml \
  --version ${VERSION} \
  --wait
