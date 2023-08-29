locals {
  chart_repo          = "https://kubernetes.github.io/ingress-nginx"
  chart_name          = "ingress-nginx"
  release_name        = "ingress-nginx"
  k8s_namespace       = "ingress-nginx"
  dhparam_secret_name = "nginx-dh-param"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.k8s_namespace
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "random_integer" "dhparam_file_id" {
  count = var.dhparam_pem == "" ? 1 : 0
  min   = 1
  max   = 5
}

locals {
  dhparam      = var.dhparam_pem == "" ? file("${path.module}/dhparam/dhparams.4096.${random_integer.dhparam_file_id[0].result}.pem") : var.dhparam_pem
  chart_values = var.chart_extra_values == "" ? [file("${path.module}/helm.values.yaml")] : [file("${path.module}/helm.values.yaml"), var.chart_extra_values]
}

resource "kubernetes_secret" "nginx-dh-param" {
  metadata {
    name      = local.dhparam_secret_name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  data = {
    "dhparam.pem" = local.dhparam
  }
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on       = [kubernetes_namespace.namespace, kubernetes_secret.nginx-dh-param]
  name             = local.release_name
  repository       = local.chart_repo
  chart            = local.chart_name
  version          = var.chart_version
  namespace        = local.k8s_namespace
  force_update     = true
  wait             = true
  create_namespace = false
  values           = local.chart_values
  dynamic "set" {
    for_each = var.chart_values_overrides
    content {
      name  = set.key
      value = set.value
    }
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.public_ip_address
  }
  set {
    name  = "controller.config.ssl-dh-param"
    value = "${local.k8s_namespace}/${local.dhparam_secret_name}"
  }
}
