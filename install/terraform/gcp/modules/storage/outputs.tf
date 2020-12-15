locals {
  credentials = {
    service_account_key = base64decode(google_service_account_key.gitpod_storage.private_key)
  }
}

output "credentials" {
  value = jsonencode(local.credentials)
}
