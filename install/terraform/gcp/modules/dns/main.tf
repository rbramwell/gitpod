locals {
  dns_prefixes = ["", "*.", "*.ws."]
}

data "google_dns_managed_zone" "gitpod" {
  name = var.zone_name
  project = var.project
}

resource "google_compute_address" "gitpod" {
  name    = var.name
  project = var.project
  region  = var.region
}

resource "google_dns_record_set" "gitpod" {
  count        = length(local.dns_prefixes)
  name         = "${local.dns_prefixes[count.index]}${var.subdomain}.${data.google_dns_managed_zone.gitpod.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.gitpod.name
  rrdatas      = [google_compute_address.gitpod.address]
  project      = var.project
}


resource "google_service_account" "dns" {
  account_id   = var.name
  display_name = var.name
  description  = "Gitpod DNS Admin ${var.name}"
  project      = var.project
}

resource "google_project_iam_member" "dns" {
  project = var.project
  role    = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.dns.email}"
}

resource "google_service_account_key" "dns" {
  service_account_id = google_service_account.dns.name
}

resource "local_file" "dns_service_account_key" {
  content = base64decode(google_service_account_key.dns.private_key)
  filename = "./secrets/dns-credentials.key"
  file_permission = "0600"
}
