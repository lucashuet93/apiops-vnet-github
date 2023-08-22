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