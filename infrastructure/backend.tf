resource "azurerm_resource_group" "backend_rg" {
  name     = var.backend_rg_name
  location = var.location
}

module "aks" {
  source   = "./modules/azure-public-aks"
  aks_name = var.aks_name
  aks_rg   = azurerm_resource_group.backend_rg.name
}

resource "azurerm_role_assignment" "aks_pull_acr" {
  depends_on           = [module.aks]
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
    cluster_ca_certificate = module.aks.cluster_ca_certificate
  }
}

resource "azurerm_public_ip" "ingress_nginx_public_ip" {
  name                = "${var.aks_name}-ingress-nginx"
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  ip_tags             = {}
  tags = {
    k8s-azure-cluster-name = var.aks_name
    k8s-azure-service      = "ingress-nginx/ingress-nginx-controller"
  }
}

module "ingress-nginx" {
  depends_on        = [module.aks, azurerm_public_ip.ingress_nginx_public_ip]
  source            = "./modules/kubernetes-ingress-nginx"
  public_ip_address = azurerm_public_ip.ingress_nginx_public_ip.ip_address
  providers = {
    helm = helm
  }
}

#module "cert-manager" {
#  source     = "./modules/kubernetes-cert-manager"
#  acme_email = "a.ageyev@gmail.com"
#  providers = {
#    helm    = helm
#    kubectl = kubectl
#  }
#}

resource "azurerm_dns_a_record" "backend_a_records" {
  for_each            = toset(var.backend_endpoints)
  name                = each.value
  zone_name           = azurerm_dns_zone.public_dns_zone.name
  resource_group_name = azurerm_resource_group.services_rg.name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_nginx_public_ip.ip_address]
}
