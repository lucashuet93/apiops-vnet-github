output "apim" {
  description = "Deployed resource names."
  value = {
    resource_group_name = azurerm_resource_group.rg.name
    apim_name           = azurerm_api_management.apim.name
    app_insights_name   = azurerm_application_insights.application_insights.name
    key_vault_name      = azurerm_key_vault.key_vault.name
  }
}
