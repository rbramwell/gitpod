#
# Service Account
#

resource "google_service_account" "gitpod_storage" {
  account_id   = "gitpod-storage-${var.name}"
  display_name = "gitpod-storage-${var.name}"
  description  = "gitpod-workspace-syncer ${var.name}"
  project      = var.project
}

resource "google_project_iam_member" "gitpod_storage" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gitpod_storage.email}"
}

resource "google_service_account_key" "gitpod_storage" {
  service_account_id = google_service_account.gitpod_storage.name
}
