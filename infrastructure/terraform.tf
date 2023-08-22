terraform {
  required_version = ">=1.5.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 0.7.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "infra"
    storage_account_name = "apimmvetfstate"
    container_name       = "tfstate"
    key                  = "apim-mve.tfstate"
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
  skip_provider_registration = true
  features {}
}

#provider "azuread" {
#}
#
#data "azurerm_client_config" "current" {}
