data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.location
}

resource "azurerm_role_assignment" "sp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = var.service_principal_object_id
}

resource "azurerm_api_management" "apim" {
  name                = "apim-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Company"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                       = "la-${var.prefix}-${var.environment}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

resource "azurerm_application_insights" "application_insights" {
  name                       = "ai-${var.prefix}-${var.environment}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  workspace_id               = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type           = "web"
  internet_ingestion_enabled = false
  internet_query_enabled     = false
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

resource "azurerm_key_vault" "key_vault" {
  name                = "kv-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }

  network_acls {
    bypass         = "None"
    default_action = "Allow"
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}

resource "azurerm_key_vault_secret" "application_insights_instrumentation_key" {
  name         = "kvs-aikey"
  value        = azurerm_application_insights.application_insights.instrumentation_key
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_access_policy" "key_vault_apim_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  object_id    = azurerm_api_management.apim.identity[0].principal_id
  tenant_id    = azurerm_api_management.apim.identity[0].tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
