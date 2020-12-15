#
# Network Configuration
#

resource "google_compute_global_address" "gitpod" {
  name          = var.name
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  network       = var.network.id
  project       = var.project
}

resource "google_service_networking_connection" "gitpod" {
  network                 = var.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.gitpod.name]
}



#
# Google Service Account
#

resource "google_service_account" "gitpod_database" {
  account_id   = var.name
  display_name = var.name
  description  = "Gitpod Database Account ${var.name}"
  project      = var.project
}

resource "google_project_iam_binding" "gitpod_database" {
  project = var.project
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.gitpod_database.email}"
  ]
}

resource "google_service_account_key" "gitpod_database" {
  service_account_id = google_service_account.gitpod_database.name
}

resource "random_id" "database" {
  byte_length = 4
}

resource "google_sql_database_instance" "gitpod" {
  name   = "${var.name}-${random_id.database.hex}"
  region = var.region
  database_version = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network.id
    }
  }
  depends_on = [
    google_service_networking_connection.gitpod
  ]
}

resource "google_sql_database" "gitpod" {
  name      = "gitpod"
  instance  = google_sql_database_instance.gitpod.name
  charset   = "utf8mb4"
  collation = "utf8mb4_bin"
}

resource "google_sql_database" "gitpod_sessions" {
  name      = "gitpod-sessions"
  instance  = google_sql_database_instance.gitpod.name
  charset   = "utf8mb4"
  collation = "utf8mb4_bin"
}

resource "random_password" "gitpod_db_user" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_sql_user" "gitpod" {
  name     = "gitpod"
  instance = google_sql_database_instance.gitpod.name
  host     = "10.%"
  password = random_password.gitpod_db_user.result
  project  = var.project
}



#
# Network Peering
#

resource "google_compute_network_peering_routes_config" "servicenetwork" {
  peering = "servicenetworking-googleapis-com"
  network = var.network.name

  import_custom_routes = true
  export_custom_routes = true
  
  depends_on = [
    google_sql_database_instance.gitpod
  ]
}

resource "google_compute_network_peering_routes_config" "cloudsql" {
  peering = "cloudsql-mysql-googleapis-com"
  network = var.network.name

  import_custom_routes = true
  export_custom_routes = true

  depends_on = [
    google_sql_database_instance.gitpod
  ]
}
