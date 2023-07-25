# API Ops in an Azure Virtual Network

## Pre-Requisites

- Terraform

## Deploying the Infrastructure

`terraform apply --var-file=terraform.tfvars`

## Create GitHub Environments

Each deployed resource group that includes an APIM service should have a corresponding GitHub Environment. Create a service principal with the contributor role to one of the resource groups hosting an APIM instance:

`az ad sp create-for-rbac -n "apiopslab" --role Contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --sdk-auth`

Next, create a new environment with the following secrets, taking values from the returned JSON and from the terraform outputs.

- `API_MANAGEMENT_SERVICE_NAME`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_RESOURCE_GROUP_NAME`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

Repeat for each resource group.
