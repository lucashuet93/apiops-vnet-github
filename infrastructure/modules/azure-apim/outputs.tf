output "name" {
  value = local.apim_name
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "application_insights_instrumentation_key" {
  sensitive = true
  value     = azurerm_application_insights.application_insights.instrumentation_key
}

output "apim_access_object_id" {
  value     = azurerm_api_management.apim.identity[0].principal_id
  sensitive = true
}

output "apim_access_tenant_id" {
  value     = azurerm_api_management.apim.identity[0].tenant_id
  sensitive = true
}
