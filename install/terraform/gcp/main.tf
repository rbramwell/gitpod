resource "google_compute_network" "gitpod" {
  name                    = "gitpod"
  description             = "Gitpod Cluster Network"
  auto_create_subnetworks = true
  project                 = var.project
}

module "kubernetes" {
  source = "./modules/kubernetes"

  name    = "gitpod"
  network = google_compute_network.gitpod.name
  project = var.project
  region  = var.region
}


module "kubeconfig" {
  source = "./modules/kubeconfig"

  cluster = {
    name = "gitpod"
  }

  depends_on = [ 
    module.kubernetes
  ]
}

module "dns" {
  source = "./modules/dns"

  project   = var.project
  region    = var.region
  zone_name = var.zone_name
  name      = "gitpod-dns"
  subdomain = var.subdomain
}


# resource "local_file" "dns_credentials" {
#   filename = "${path.root}/secrets/dns_service_account_key.json"
#   content  = base64decode(jsondecode(module.dns.credentials).service_account_key)
#   file_permission = 0600
# }


# module "registry" {
#   source = "./modules/registry"

#   name = var.environment
#   project  = var.project
#   location = var.container_registry.location

#   providers = {
#     google = google
#     kubernetes = kubernetes
#   }
# }


# module "storage" {
#   source = "./modules/storage"

#   name = var.environment
#   project  = var.project
#   location = "EU"
# }

# module "database" {
#   source = "./modules/database"

#   project = var.project
#   name    = var.database.name
#   region  = var.region
#   network = {
#     id   = google_compute_network.gitpod.id
#     name = google_compute_network.gitpod.name
#   }
# }


# module "certificates" {
#   source = "./modules/certmanager"

#   project = var.project
#   certificate = {
#     name      = "gitpod-certificate"
#     domain    = module.dns.domain
#     email     = var.certificate_email
#     namespace = var.kubernetes.namespace
#   }
#   kubeconfig = module.kubeconfig.path
# }


#   depends_on = [
#     module.kubernetes
#   ]
# }

# #
# # Gitpod
# #

# module "gitpod" {
#   source = "./modules/gitpod"

#   project = var.project
#   region  = var.region
#   kubernetes = {
#     namespace = var.kubernetes.namespace
#   }
#   values               = file("values.yaml")
#   registry_credentials = module.registry.credentials
#   database_credentials = module.database.credentials
#   storage_credentials  = module.storage.credentials
#   dns_credentials      = module.dns.credentials
#   certificate          = module.certificates

#   path           = "../../../chart/"
#   # authProviders  = var.authProviders
#   license = var.license
