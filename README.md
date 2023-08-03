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

## Deploying the Infrastructure

Navigate to the [infrastructure](./infrastructure/) folder and update the [terraform.tfvars](./infrastructure/terraform.tfvars) file with an Azure region and unique `prefix`. Next run the following from a terminal: -

`make deploy`

## Create GitHub Environments

Each deployed resource group that includes an APIM service should have a corresponding GitHub Environment. Create a service principal with the contributor role for the dev resource group:

`az ad sp create-for-rbac -n "apiopslab" --role Contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --sdk-auth`

Next, navigate to the Settings blade in the Github repository and create a new environment called `dev` with the following secrets, taking values from the JSON returned from the `az` command and from the terraform outputs.

- `API_MANAGEMENT_SERVICE_NAME`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_RESOURCE_GROUP_NAME`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

Repeat for the prod resource group.

## Update the dev APIM instance

Navigate to the [Azure Portal](https://portal.azure.com/) and find the dev APIM instance. Update the configuration in some way - add a product, an API, a named value, etc.

## Run the Extractor and Publisher pipelines

Navigate to the Actions blade in the GitHub repository and run the Extractor pipeline. When the pipeline completes, merge the newly opened Pull Request, which triggers the Publisher pipeline.

Confirm that the changes made to the dev APIM instance in the Azure portal cascaded successfully to the prod APIM instance.
