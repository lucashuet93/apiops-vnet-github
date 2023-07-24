terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

#  dev instance of API Management
resource "azurerm_resource_group" "rg_dev" {
  name     = "${var.prefix}-rg-dev"
  location = var.location
}

resource "azurerm_api_management" "apim_dev" {
  name                = "${var.prefix}-apim-dev"
  location            = azurerm_resource_group.rg_dev.location
  resource_group_name = azurerm_resource_group.rg_dev.name
  publisher_name      = "Company"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"
}

#  prod instance of API Management
resource "azurerm_resource_group" "rg_prod" {
  name     = "${var.prefix}-rg-prod"
  location = var.location
}

resource "azurerm_api_management" "apim_prod" {
  name                = "${var.prefix}-apim-prod"
  location            = azurerm_resource_group.rg_dev.location
  resource_group_name = azurerm_resource_group.rg_dev.name
  publisher_name      = "Company"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"
}
