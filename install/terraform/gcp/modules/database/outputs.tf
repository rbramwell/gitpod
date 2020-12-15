locals {
    credentials = {
      instance = google_sql_database_instance.gitpod.connection_name
      host     = google_sql_database_instance.gitpod.first_ip_address
      username = google_sql_user.gitpod.name
      password = google_sql_user.gitpod.password
      service_account_key = base64decode(google_service_account_key.gitpod_database.private_key)
    }
}

output "credentials" {
  value = jsonencode(local.credentials)
}
