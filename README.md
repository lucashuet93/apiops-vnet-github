# API Ops in an Azure Virtual Network

The accelerator demonstrates use of [API Ops](https://azure.github.io/apiops/apiops/0-labPrerequisites/) to deploy changes from a development to production API Management instance that are hosted in separate Azure Virtual Networks.

Terraform is used to deploy the supporting infrastructure, including the API Management instances, and API Ops handles configuration promotion from the development to production environment.

## Architecture

Two resource groups are deployed, dev and prod, that contain identical resources. A developer SKU instance of API Management is deployed in internal mode into a dedicated subnet in a virtual network. The subnets have NSGs with [required rules](https://learn.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#configure-nsg-rules) applied and the API Management instance is configured to use the [required Azure Public IP resource](https://learn.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#prerequisites).

![Architecture](./assets/architecture.png)

The API Ops tool does not require additional considerations be made for the VNet - it operates the same way whether API Management is publicly accessible or not. When deployed in internal or external mode in an Azure Virtual Network, API Management requires a [Public IP address](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses), which is used to expose management operations. The API Ops tool's executables use the management endpoints to read and update API Management resources, so the pipelines are able to make configuration changes to the two instances while they remain publicly inaccessible for consumption.

## Pre-Requisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

This repository comes with a [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) and all of the pre-requisites are already installed if you use it.

## Deploying the Infrastructure

Make a copy of the `.env.example` and call it `.env`; then define an Azure region, unique `prefix` and your Azure Subscription Id. Next run the following from a terminal: -

`make infra`

## Create GitHub Environments

Each deployed resource group that includes an APIM service should have a corresponding GitHub Environment. If your logged in Azure user is an Application Administrator in the tenant, the `make infra` step would have created an Enterprise Application and granted Contributor to each of the resource groups. 

This is equivalent of running: -

`az ad sp create-for-rbac -n "apiopslab" --role Contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --sdk-auth`

After you have deployed the infrastructure, the `.env` will have been amended to include the settings that you need to configure GitHub Actions. Navigate to the Settings blade in the Github repository and create a new environment called `dev` with the following secrets, taking values from the environment file.

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `API_MANAGEMENT_SERVICE_NAME` (Use `DEV_APIM_NAME`)
- `AZURE_RESOURCE_GROUP_NAME` (Use `DEV_RESOURCE_GROUP_NAME`)


Create a new `prod` environment using the same settings but remembering to use the prod values

- `API_MANAGEMENT_SERVICE_NAME` (Use `PROD_APIM_NAME`)
- `AZURE_RESOURCE_GROUP_NAME` (Use `PROD_RESOURCE_GROUP_NAME`)

## Update the development API Management instance

Navigate to the [Azure Portal](https://portal.azure.com/) and find the dev APIM instance. Update the configuration in some way - add a product, an API, a named value, etc.

## Run the Extractor and Publisher pipelines

Navigate to the Actions blade in the GitHub repository and run the Extractor pipeline. When the pipeline completes, merge the newly opened Pull Request, which triggers the Publisher pipeline.

Confirm that the changes made to the dev APIM instance in the Azure portal cascaded successfully to the prod APIM instance.
