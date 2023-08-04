terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.67.0"
    }
  }

  required_version = ">= 0.15.3"
}

provider "azurerm" {
  features {}
}

#  dev instance of API Management
resource "azurerm_resource_group" "dev_rg" {
  name     = "${var.prefix}-rg-dev"
  location = var.location
}

resource "azurerm_public_ip" "dev_pip" {
  name                = "${var.prefix}-pip-dev"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-pip-dev"
}

resource "azurerm_virtual_network" "dev_vnet" {
  name                = "${var.prefix}-vnet-dev"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "dev_apim_nsg" {
  name                = "${var.prefix}-nsg-apim-dev"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location

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

resource "azurerm_subnet" "dev_default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "dev_apim_subnet" {
  name                 = "${var.prefix}-subnet-apim-dev"
  resource_group_name  = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "dev_apim_subnet_nsg" {
  subnet_id                 = azurerm_subnet.dev_apim_subnet.id
  network_security_group_id = azurerm_network_security_group.dev_apim_nsg.id
}

resource "azurerm_api_management" "dev_apim" {
  name                 = "${var.prefix}-apim-dev"
  location             = azurerm_resource_group.dev_rg.location
  resource_group_name  = azurerm_resource_group.dev_rg.name
  publisher_name       = "Company"
  publisher_email      = "company@terraform.io"
  sku_name             = "Developer_1"
  public_ip_address_id = azurerm_public_ip.dev_pip.id
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.dev_apim_subnet.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.dev_apim_subnet_nsg]
}

#  prod instance of API Management
resource "azurerm_resource_group" "prod_rg" {
  name     = "${var.prefix}-rg-prod"
  location = var.location
}

resource "azurerm_public_ip" "prod_pip" {
  name                = "${var.prefix}-pip-prod"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = azurerm_resource_group.prod_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-pip-prod"
}

resource "azurerm_virtual_network" "prod_vnet" {
  name                = "${var.prefix}-vnet-prod"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = azurerm_resource_group.prod_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "prod_apim_nsg" {
  name                = "${var.prefix}-nsg-apim-prod"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = azurerm_resource_group.prod_rg.location

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

resource "azurerm_subnet" "prod_default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "prod_apim_subnet" {
  name                 = "${var.prefix}-subnet-apim-prod"
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "prod_apim_subnet_nsg" {
  subnet_id                 = azurerm_subnet.prod_apim_subnet.id
  network_security_group_id = azurerm_network_security_group.prod_apim_nsg.id
}

resource "azurerm_api_management" "prod_apim" {
  name                 = "${var.prefix}-apim-prod"
  location             = azurerm_resource_group.prod_rg.location
  resource_group_name  = azurerm_resource_group.prod_rg.name
  publisher_name       = "Company"
  publisher_email      = "company@terraform.io"
  sku_name             = "Developer_1"
  public_ip_address_id = azurerm_public_ip.prod_pip.id
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.prod_apim_subnet.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.prod_apim_subnet_nsg]
}
