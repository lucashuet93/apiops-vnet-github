data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.location
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = var.service_principal_object_id
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "pip-${var.prefix}-${var.environment}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "nsg-default-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule = []
}

resource "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-apim-${var.prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "apimvnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "lbvnet-in"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "vnetstorage-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
  }

  security_rule {
    name                       = "vnetsql-out"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "SQL"
  }

  security_rule {
    name                       = "vnetkv-out"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureKeyVault"
  }
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "subnet-apim-${var.prefix}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "default_subnet_nsg" {
  subnet_id                 = azurerm_subnet.default_subnet.id
  network_security_group_id = azurerm_network_security_group.default_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet_nsg" {
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = azurerm_network_security_group.apim_nsg.id
}

resource "azurerm_api_management" "apim" {
  name                 = "apim-${var.prefix}-${var.environment}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  publisher_name       = "Company"
  publisher_email      = "company@terraform.io"
  sku_name             = "Developer_1"
  public_ip_address_id = azurerm_public_ip.pip.id
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_subnet_network_security_group_association.apim_subnet_nsg]
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "la-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "application_insights" {
  name                = "ai-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
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
    certificate_permissions = [
      "Get",
      "List",
      "Import",
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


# resource "azurerm_network_security_group" "private_endpoint_nsg" {
#   name                = "nsg-pe-${var.prefix}-${var.environment}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   security_rule = []
# }

# resource "azurerm_subnet" "private_endpoint_subnet" {
#   name                                      = "subnet-pe-${var.prefix}-${var.environment}"
#   resource_group_name                       = azurerm_resource_group.rg.name
#   virtual_network_name                      = azurerm_virtual_network.vnet.name
#   address_prefixes                          = ["10.0.2.0/24"]
#   private_endpoint_network_policies_enabled = true
# }

# resource "azurerm_subnet_network_security_group_association" "private_endpoint_subnet_nsg" {
#   subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
#   network_security_group_id = azurerm_network_security_group.private_endpoint_nsg.id
# }

# resource "azurerm_private_dns_zone" "key_vault_private_dns_zone" {
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_private_dns_zone_vnet_link" {
#   name                  = "kv-${var.prefix}-${var.environment}-link"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.key_vault_private_dns_zone.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# resource "azurerm_private_endpoint" "key_vault_private_endpoint" {
#   name                = "kv-${var.prefix}-${var.environment}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.private_endpoint_subnet.id

#   private_service_connection {
#     name                           = "kv-private-service-connection"
#     private_connection_resource_id = azurerm_key_vault.key_vault.id
#     subresource_names              = ["vault"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "kv-private-dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.key_vault_private_dns_zone.id]
#   }
# }
