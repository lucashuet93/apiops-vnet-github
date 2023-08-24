data "azuread_client_config" "current" {}

data "azurerm_role_definition" "aks_cluster_user" {
  role_definition_id = "4abbcc35-e782-43d8-92c5-2d3f1bd2253f"
}
