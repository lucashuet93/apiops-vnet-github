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
