resource "google_service_account" "gitpod_registry" {
  account_id   = "gitpod-registry-${var.name}"
  display_name = "gitpod-registry-${var.name}"
  description  = "Gitpod Registry ${var.name}"
  project      = var.project
}

resource "google_project_iam_member" "gitpod_registry" {
  project = var.project
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gitpod_registry.email}"
}

resource "google_service_account_key" "gitpod_registry" {
  service_account_id = google_service_account.gitpod_registry.name
}
