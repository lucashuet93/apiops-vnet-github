// common services resources

resource "azurerm_resource_group" "services_rg" {
  name     = var.services_rg_name
  location = var.location
}

// Uncomment if you manage DNS zone
#resource "azurerm_dns_zone" "public_dns_zone" {
#  name                = var.dns_domain
#  resource_group_name = azurerm_resource_group.services_rg.name
#}

resource "azurerm_container_registry" "acr" {
  name                    = var.acr_name
  resource_group_name     = azurerm_resource_group.services_rg.name
  location                = azurerm_resource_group.services_rg.location
  sku                     = "Standard"
  admin_enabled           = false
  anonymous_pull_enabled  = false
  data_endpoint_enabled   = false
  zone_redundancy_enabled = false
}

resource "azurerm_key_vault" "akv" {
  name                       = var.akv_name
  location                   = azurerm_resource_group.services_rg.location
  resource_group_name        = azurerm_resource_group.services_rg.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = false
  soft_delete_retention_days = 90
}
