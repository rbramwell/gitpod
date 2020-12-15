#
resource "google_service_account" "certmanager" {
  account_id   = var.certmanager.name
  display_name = var.certmanager.name
  description  = "Cert-Manager Account ${var.certmanager.name}"
  project      = var.project
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.certmanager.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
resource "google_service_account_key" "certmanager" {
  service_account_id = google_service_account.certmanager.name
}


#
# Kubernetes Resources
#

resource "kubernetes_namespace" "certmanager" {
    provider = kubernetes
    metadata {
        name = var.certmanager.namespace
    }
}

#
resource "kubernetes_secret" "certmanager" {
    provider = kubernetes
    metadata {
        name      = "clouddns-dns01-solver-svc-acct"
        namespace = kubernetes_namespace.certmanager.metadata[0].name
    }
    data = {
        "credentials.json" = base64decode(google_service_account_key.certmanager.private_key)
    }
}


resource "null_resource" "crds" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${path.root}/${var.kubeconfig} apply --validate=false -f ${var.certmanager.crds_url}"
  }
}

# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "certmanager" {
  name       = var.certmanager.name
  chart      = var.certmanager.chart
  repository = var.certmanager.repository

  namespace        = kubernetes_namespace.certmanager.metadata[0].name
  create_namespace = false

  wait = true

  set {
    name  = "installCRDs"
    value = "false"
  }

  depends_on = [
    null_resource.crds
  ]
}

locals {
  clusterissuer = {
    name     = "letsencrypt-issuer"
    key_name = "letsencrypt-private-key"
  }
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "cluster_issuer" {
  template = file("${path.module}/templates/clusterissuer.tpl")

  vars = {
    name        = local.clusterissuer.name
    email       = var.certificate.email
    project     = var.project
    key_name    = local.clusterissuer.key_name
    secret_name = kubernetes_secret.certmanager.metadata[0].name
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "clusterissuer" {
  content  = data.template_file.cluster_issuer.rendered
  filename = "${path.root}/clusterissuer.yaml"

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${path.root}/${var.kubeconfig} apply --validate=false -f ${path.root}/clusterissuer.yaml"
  }
}


# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "certificate" {
  template = file("${path.module}/templates/certificate.tpl")

  vars = {
    name      = var.certificate.name
    namespace = var.certificate.namespace
    domain    = var.certificate.domain
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "certificate" {
  content  = data.template_file.certificate.rendered
  filename = "${path.root}/certificate.yaml"

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${path.root}/${var.kubeconfig} apply --validate=false -f ${path.root}/certificate.yaml"
  }
}
