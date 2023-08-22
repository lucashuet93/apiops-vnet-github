## The current logged in user will be the owner of the application

# TODO:

# Deploy helm - AKS admin

# push APIm config to dev
# push APIm config to dev

# push APIm config to dev


resource "azuread_application" "apim_app" {
  display_name = "api_ops_app"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "apim_spn" {
  application_id = azuread_application.apim_app.application_id
  owners         = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "spn" {
  service_principal_id = azuread_service_principal.apim_spn.id
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
