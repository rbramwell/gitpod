locals {
  roles = [
    "roles/clouddebugger.agent",
    "roles/cloudtrace.agent",
    "roles/errorreporting.writer",
    "roles/logging.viewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
  ]
}

resource "google_compute_subnetwork" "gitpod" {
  name                     = "${var.name}-subnet"
  ip_cidr_range            = "10.23.0.0/16"
  region                   = var.region
  network                  = var.network
  private_ip_google_access = true
}

resource "google_service_account" "gitpod" {
  account_id   = "${var.name}-nodes"
  display_name = "${var.name}-nodes"
  description  = "Gitpod Nodes ${var.name}"
  project      = var.project
}

resource "google_project_iam_member" "gitpod" {
  count   = length(local.roles)
  project = var.project
  role    = local.roles[count.index]
  member = "serviceAccount:${google_service_account.gitpod.email}"
}

resource "google_container_cluster" "gitpod" {
  name     = var.name
  project  = var.project
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  default_max_pods_per_node = 110

  pod_security_policy_config {
    enabled = true
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  network    = var.network
  subnetwork = google_compute_subnetwork.gitpod.id

  ip_allocation_policy {}

  min_master_version = "1.16"
}

resource "google_container_node_pool" "gitpod" {

  name       = "nodepool-0"
  location   = var.region
  cluster    = google_container_cluster.gitpod.name
  
  initial_node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-8"
    disk_size_gb = 100
    disk_type    = "pd-ssd"
    local_ssd_count = 1

    workload_metadata_config {
      node_metadata = "SECURE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      "gitpod.io/workload_meta" = "true"
      "gitpod.io/workload_workspace" = "true"
    }

    image_type = "UBUNTU_CONTAINERD"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]

    service_account = google_service_account.gitpod.email
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }
}
