#!/usr/bin/env bash

helm -n apim-be-dev upgrade --install apim-demo-app oci://gcacrapim.azurecr.io/charts/apim-demo-app \
  -f dev.yaml \
  --set-file apim.policy=apim/policy.xml \
  --version 0.0.1-38 \
  --wait
