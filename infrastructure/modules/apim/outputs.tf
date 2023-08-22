output "apim" {
  description = "Deployed resource names."
  value = {
    resource_group_name = azurerm_resource_group.rg.name
    apim_name           = azurerm_api_management.apim.name
  }
}