#
# Provider
#

provider "google" {
  project = var.project
  region  = var.region
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  load_config_file = "false"

  host                   = module.kubernetes.cluster.endpoint
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.kubernetes.cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file = "false"

    host                   = module.kubernetes.cluster.endpoint
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(module.kubernetes.cluster.master_auth[0].cluster_ca_certificate)
  }
}

