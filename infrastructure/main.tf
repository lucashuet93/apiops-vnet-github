# SP's to manage APIM's from Kubernetes
locals {
  backend_environments = concat(var.dev_backend_environments, var.prod_backend_environments)
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

// Dev APIM
module "apim_dev" {
  source = "./modules/azure-apim"
  name   = "apim-dev"
  akv_id = azurerm_key_vault.akv.id
  contributors_sp_object_ids = [
    azuread_service_principal.apim_backend_spns["apim-be-dev"].object_id,
    azuread_service_principal.apim_backend_spns["apim-be-test"].object_id
  ]
}

resource "kubernetes_secret" "dev_apim_access" {
  depends_on = [module.apim_dev]
  for_each   = toset(var.dev_backend_environments)
  metadata {
    name      = "apim-access"
    namespace = each.value
  }
  data = {
    AZURE_CLIENT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    AZURE_CLIENT_SECRET         = azuread_service_principal_password.apim_backend_spn_passwords[each.value].value
    AZURE_SUBSCRIPTION_ID       = data.azurerm_client_config.current.subscription_id
    AZURE_TENANT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    API_MANAGEMENT_SERVICE_NAME = module.apim_dev.name
    AZURE_RESOURCE_GROUP_NAME   = module.apim_dev.rg_name
  }
}

// Prod APIM
module "apim_prod" {
  source = "./modules/azure-apim"
  name   = "apim-prod"
  akv_id = azurerm_key_vault.akv.id
  contributors_sp_object_ids = [
    azuread_service_principal.apim_backend_spns["apim-be-prod"].object_id,
    azuread_service_principal.apim_backend_spns["apim-be-stage"].object_id
  ]
}

resource "kubernetes_secret" "prod_apim_access" {
  depends_on = [module.apim_prod]
  for_each   = toset(var.prod_backend_environments)
  metadata {
    name      = "apim-access"
    namespace = each.value
  }
  data = {
    AZURE_CLIENT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    AZURE_CLIENT_SECRET         = azuread_service_principal_password.apim_backend_spn_passwords[each.value].value
    AZURE_SUBSCRIPTION_ID       = data.azurerm_client_config.current.subscription_id
    AZURE_TENANT_ID             = azuread_service_principal.apim_backend_spns[each.value].application_id
    API_MANAGEMENT_SERVICE_NAME = module.apim_prod.name
    AZURE_RESOURCE_GROUP_NAME   = module.apim_prod.rg_name
  }
}
