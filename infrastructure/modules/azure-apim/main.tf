resource "random_integer" "api_management_suffix" {
  min = 10
  max = 99
}

locals {
  apim_name = "${var.name}-${random_integer.api_management_suffix.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.name}"
  location = var.location
}

resource "azurerm_role_assignment" "sp_contributors" {
  for_each             = toset(var.contributors_sp_object_ids)
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_api_management" "apim" {
  name                = local.apim_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Backbase"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "la-${local.apim_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "ai-${local.apim_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "apim_diagnostic_setting" {
  name                       = "apimdiagnosticsetting"
  target_resource_id         = azurerm_api_management.apim.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_key_vault_access_policy" "key_vault_apim_access_policy" {
  key_vault_id = var.akv_id
  object_id    = azurerm_api_management.apim.identity[0].principal_id
  tenant_id    = azurerm_api_management.apim.identity[0].tenant_id
  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "application_insights_instrumentation_key" {
  name         = "${var.name}-kvs-aikey"
  value        = azurerm_application_insights.application_insights.instrumentation_key
  key_vault_id = var.akv_id
}
