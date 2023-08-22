locals {
  acme_url             = "https://acme-v02.api.letsencrypt.org/directory"
  chart_repo           = "https://charts.jetstack.io"
  chart_name           = "cert-manager"
  k8s_namespace        = "cert-manager"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.k8s_namespace
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "kubernetes_secret" "letsencrypt" {
  count = var.letsencrypt_tls_key == "" ? 0 : 1
  metadata {
    name      = "letsencrypt"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  data = {
    "tls.key" = var.letsencrypt_tls_key
  }
  # ignore change so secret is not updated on every run
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = local.chart_repo
  chart            = local.chart_name
  version          = var.chart_version
  namespace        = local.k8s_namespace
  force_update     = true
  create_namespace = false
  wait             = true
  timeout          = 300
  values           = [file("${path.module}/helm-chart-values.template.yaml")]
}

resource "kubectl_manifest" "issuer" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = templatefile("${path.module}/issuer.letsencrypt.template.yaml", { acme_email  = var.acme_email, acme_url = local.acme_url } )
}
