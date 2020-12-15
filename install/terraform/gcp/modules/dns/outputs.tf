locals {
  credentials = {
    domain = trimsuffix("${var.subdomain}.${data.google_dns_managed_zone.gitpod.dns_name}",".")
    address = google_compute_address.gitpod.address
    service_account_key = google_service_account_key.dns.private_key
  }
}

output "credentials" {
  value = jsonencode(local.credentials)
}

output "domain" {
  value = trimsuffix("${var.subdomain}.${data.google_dns_managed_zone.gitpod.dns_name}",".")
}