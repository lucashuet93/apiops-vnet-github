terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.67.0"
    }
  }

  required_version = ">= 0.15.3"
}

provider "azurerm" {
  features {}
}

module "apim_dev" {
  source = "./apim"
  location = var.location
  prefix = var.prefix
  environment = "dev"
}

module "apim_prod" {
  source = "./apim"
  location = var.location
  prefix = var.prefix
  environment = "prod"
}
