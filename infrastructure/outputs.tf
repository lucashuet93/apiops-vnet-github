output "dev_apim" {
  description = "Deployed resource groups names."
  value = {
    resource_group_name = azurerm_resource_group.dev_rg.name
    apim_name           = azurerm_api_management.dev_apim.name
  }
}

output "prod_apim" {
  description = "Deployed resource groups names."
  value = {
    resource_group_name = azurerm_resource_group.prod_rg.name
    apim_name           = azurerm_api_management.prod_apim.name
  }
}
