locals {
  registry_credentials      = jsondecode(var.registry_credentials)
  database_credentials      = jsondecode(var.database_credentials)
  storage_credentials       = jsondecode(var.storage_credentials)
  # certificates_credentials  = jsondecode(var.certificates_credentials)
  dns_credentials           = jsondecode(var.dns_credentials)
}


#
# Certificates
#

data "template_file" "certificates_values" {
  template = file("${path.module}/templates/values.certificates.tpl")
  vars = {
    secretName = var.certificate.name
  }
}



#
# Registry
#

data "template_file" "registry" {
  template = file("${path.module}/templates/registry-auth.tpl")
  vars = {
    auth = local.registry_credentials.auth
  }
}

resource "kubernetes_secret" "registry" {
  metadata {
    name      = "gitpod-registry"
    namespace = var.kubernetes.namespace
  }

  data = {
    ".dockerconfigjson" = data.template_file.registry.rendered
  }

  type = "kubernetes.io/dockerconfigjson"
}

data "template_file" "registry_values" {
  template = file("${path.module}/templates/values.registry.tpl")
  vars = {
    project    = var.project
    secretName = kubernetes_secret.registry.metadata[0].name
  }
}


#
# Database
#

resource "kubernetes_secret" "database" {
  metadata {
    name      = "gcloud-sql-token"
    namespace = var.kubernetes.namespace
  }

  data = {
    "credentials.json" = local.database_credentials.service_account_key
  }
}


resource "kubernetes_secret" "gitpod_database" {
  metadata {
    name      = "gitpod-database"
    namespace = var.kubernetes.namespace
  }

  data = {
    host          = local.database_credentials.host
    user          = local.database_credentials.username
    password      = local.database_credentials.password
  }
}

resource "kubernetes_job" "mysql_initializer" {
  metadata {
    name      = "gitpod-db-initialization"
    namespace = var.kubernetes.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "db-initialization"
          image   = "gcr.io/gitpod-io/db-migrations:v0.4.0-dev-selfhosted-gitpod-db-init.15"
          command = ["/init.sh", "&&", "echo", "finished"]
          env {
            name = "MYSQL_HOST"
            value_from {
              secret_key_ref {
                name = "gitpod-database"
                key  = "host"
              }
            }
          }
          env {
            name  = "MYSQL_USER"
            value = "gitpod"
          }
          env {
            name  = "MYSQL_PORT"
            value = "3306"
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "gitpod-database"
                key  = "password"
              }
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
}

data "template_file" "database_values" {
  template = file("${path.module}/templates/values.database.tpl")
  vars = {
    host     = local.database_credentials.host
    password = local.database_credentials.password
    instance = local.database_credentials.instance
    credentials = kubernetes_secret.database.metadata[0].name
  }
}



#
# Storage
#

resource "kubernetes_secret" "storage" {
  metadata {
    name      = "gcloud-creds"
    namespace = var.kubernetes.namespace
  }

  data = {
    "key.json" = local.storage_credentials.service_account_key
  }
}

data "template_file" "storage_values" {
  template = file("${path.module}/templates/values.storage.tpl")
  vars = {
    secretName = kubernetes_secret.storage.metadata[0].name
    region     = var.region
    project    = var.project
  }
}


#
# Gitpod
#


data "template_file" "node_affinity_values" {
  template = file("${path.module}/templates/values.node-affinity.tpl")
}

data "template_file" "node_layout_values" {
  template = file("${path.module}/templates/values.node-layout.tpl")
}

data "template_file" "values" {
  template = file("${path.module}/templates/values.tpl")
  vars = {
    project        = var.project
    region         = var.region
    hostname       = local.dns_credentials.domain
    loadBalancerIP = local.dns_credentials.address
    license = var.license
  }
}

resource "helm_release" "gitpod" {
  name       = "gitpod"
  repository = "https://charts.gitpod.io"
  chart      = "gitpod"
  version    = "0.4.0"

  namespace         = var.kubernetes.namespace
  create_namespace  = false
  cleanup_on_fail   = false
  wait              = false
  dependency_update = true

  values = [
    var.values,
    data.template_file.values.rendered,
    data.template_file.database_values.rendered,
    data.template_file.registry_values.rendered,
    data.template_file.storage_values.rendered,
    data.template_file.node_affinity_values.rendered,
    data.template_file.node_layout_values.rendered,
  ]
}
