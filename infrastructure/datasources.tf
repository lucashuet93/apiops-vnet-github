data "azuread_client_config" "current" {}

data "azurerm_role_definition" "aks_cluster_admin" {
  role_definition_id = "0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8"
}

data "azurerm_role_definition" "aks_cluster_user" {
  role_definition_id = "4abbcc35-e782-43d8-92c5-2d3f1bd2253f"
}
