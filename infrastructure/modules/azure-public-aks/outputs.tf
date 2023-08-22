output "principal_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "client_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
}

output "client_key" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
}

output "cluster_ca_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

output "node_resource_group" {
  value = lower(azurerm_kubernetes_cluster.aks.node_resource_group)
}
