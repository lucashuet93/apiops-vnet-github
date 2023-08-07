terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.67.0"
    }
    azuread= {
      source  = "hashicorp/azuread"
      version = "~> 2.41.0"
    }
  }

  required_version = ">= 0.15.3"
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

provider "azuread" {
}

# Configure a Service Principal so that we can access the APIM in the different Resource Groups
data "azurerm_client_config" "current" {}

# The current logged in user will be the owner of the application
resource "azuread_application" "apim_app" {
  display_name = "api_ops_app"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "apim_spn" {
  application_id = azuread_application.apim_app.application_id
  owners         = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "spn" {
  service_principal_id = azuread_service_principal.apim_spn.id
}

module "apim_dev" {
  source = "./apim"
  location = var.location
  prefix = var.prefix
  service_principal_object_id = azuread_service_principal.apim_spn.object_id
  environment = "dev"
}

module "apim_prod" {
  source = "./apim"
  location = var.location
  prefix = var.prefix
  service_principal_object_id = azuread_service_principal.apim_spn.object_id
  environment = "prod"
}
