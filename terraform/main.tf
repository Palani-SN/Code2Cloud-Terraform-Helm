provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
  }
}