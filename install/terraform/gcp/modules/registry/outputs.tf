locals {
    credentials = {
        auth = base64encode("_json_key: ${base64decode(google_service_account_key.gitpod_registry.private_key)}")
    }
}

output "credentials" {
  value = jsonencode(local.credentials)
}
