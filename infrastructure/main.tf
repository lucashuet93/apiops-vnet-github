# SP's to manage APIM's from Kubernetes
locals {
  dev_backend_environments = [
    "apim-be-dev",
    "apim-be-test"
  ]
  prod_backend_environments = [
    "apim-be-prod",
    "apim-be-stage"
  ]
  #  backend_environments = concat(local.dev_backend_environments, local.prod_backend_environments)
  backend_environments = local.dev_backend_environments
}

resource "azuread_application" "apim_backend_apps" {
  for_each     = toset(local.backend_environments)
  display_name = each.value
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "apim_backend_spns" {
  for_each       = toset(local.backend_environments)
  application_id = azuread_application.apim_backend_apps[each.value].application_id
  owners         = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "apim_backend_spn_passwords" {
  for_each             = toset(local.backend_environments)
  service_principal_id = azuread_service_principal.apim_backend_spns[each.value].id
}

resource "kubernetes_secret" "dev_apim_access" {
  for_each = toset(local.dev_backend_environments)
  metadata {
    name      = "apim-access"
    namespace = each.value
  }
  data = {
    AZURE_CLIENT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    AZURE_CLIENT_SECRET         = azuread_service_principal_password.apim_backend_spn_passwords[each.value].value
    AZURE_SUBSCRIPTION_ID       = data.azurerm_client_config.current.subscription_id
    AZURE_TENANT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    API_MANAGEMENT_SERVICE_NAME = "DEV_APIM_NAME"
    AZURE_RESOURCE_GROUP_NAME   = "DEV_RESOURCE_GROUP_NAME"
  }
}

module "apim_dev" {
  source = "./modules/azure-apim"
  name   = "apim-dev"
  contributors_sp_object_ids = [
    azuread_service_principal.apim_backend_spns["apim-be-dev"].object_id,
    azuread_service_principal.apim_backend_spns["apim-be-test"].object_id
  ]
}


#module "apim_dev" {
#  source = "./modules/apim"
#  location = var.location
#  prefix = var.prefix
#  service_principal_object_id = azuread_service_principal.apim_spn.object_id
#  environment = "dev"
#}
#
#module "apim_prod" {
#  source = "./modules/apim"
#  location = var.location
#  prefix = var.prefix
#  service_principal_object_id = azuread_service_principal.apim_spn.object_id
#  environment = "prod"
#}
