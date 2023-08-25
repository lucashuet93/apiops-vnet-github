# output "azure_subscription_id" {
#   description = "Azure Subscription ID."
#   value       = data.azurerm_client_config.current.subscription_id
# }

# output "azure_tenant_id" {
#   description = "Azure Tenant ID."
#   value       = data.azurerm_client_config.current.tenant_id
# }

# output "apim_client_id" {
#   description = "APIM Client ID."
#   value       = azuread_application.apim_app.application_id
# }

# output "apim_client_secret" {
#   description = "APIM Client Secret."
#   value       = azuread_service_principal_password.spn.value
#   sensitive   = true
# }

# output "dev_apim_name" {
#   description = "Development APIM Name."
#   value       = module.apim_dev.apim.apim_name
# }

# output "prod_apim_name" {
#   description = "Production APIM Name."
#   value       = module.apim_prod.apim.apim_name
# }

# output "dev_resource_group_name" {
#   description = "Development Resource Group Name."
#   value       = module.apim_dev.apim.resource_group_name
# }

# output "prod_resource_group_name" {
#   description = "Production Resource Group Name."
#   value       = module.apim_prod.apim.resource_group_name
# }
