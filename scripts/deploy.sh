#!/bin/bash

set -euo pipefail

# Check the user is logged into Azure
if ! az account show 1>/dev/null; then
    echo "You must log into Azure first!"
    az login
fi

cd infrastructure

terraform init

echo "Deploying infrastructure - this will take a few minutes"
terraform apply --var-file=terraform.tfvars --auto-approve