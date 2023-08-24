resource "azurerm_kubernetes_cluster" "aks" {
  name                      = var.aks_name
  location                  = var.aks_location
  resource_group_name       = var.aks_rg
  dns_prefix                = "${var.aks_name}-dns"
  kubernetes_version        = var.aks_version
  automatic_channel_upgrade = "patch"
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "default"
    vm_size             = var.default_vm_size
    enable_auto_scaling = true
    min_count           = var.default_pool_min_nodes
    max_count           = var.default_pool_max_nodes
    os_disk_size_gb     = var.default_pool_os_disk_size_gb
    os_sku              = "Ubuntu"
    tags                = {}
  }
  network_profile {
    dns_service_ip    = var.dns_service_ip
    ip_versions       = ["IPv4"]
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
    outbound_type     = "loadBalancer"
    pod_cidr          = var.aks_pod_cidr
    service_cidr      = var.aks_service_cidr
  }
}

resource "azuread_application" "aks_cluster_user" {
  display_name = format("%s%s", var.aks_name, "-user")
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aks_cluster_user" {
  application_id = azuread_application.aks_cluster_user.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "aks_cluster_user" {
  scope              = azurerm_kubernetes_cluster.aks.id
  role_definition_id = data.azurerm_role_definition.aks_cluster_user.id
  principal_id       = azuread_service_principal.aks_cluster_user.object_id

  lifecycle {
    ignore_changes = [role_definition_id] # see https://github.com/hashicorp/terraform-provider-azurerm/issues/4258
  }
}

resource "azuread_service_principal_password" "aks_cluster_user_password" {
  service_principal_id = azuread_service_principal.aks_cluster_user.object_id
}
