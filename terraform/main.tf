terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.49.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

# Provider Init
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Required API's

resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "gke" {
  project    = var.project_id
  service    = "container.googleapis.com"
  depends_on = [google_project_service.iam]
}

resource "google_project_service" "artifact_registry" {
  project    = var.project_id
  service    = "artifactregistry.googleapis.com"
  depends_on = [google_project_service.gke]
}

resource "google_project_service" "compute" {
  project    = var.project_id
  service    = "compute.googleapis.com"
  depends_on = [google_project_service.iam]
}

# Artifact Registry Creation
resource "google_artifact_registry_repository" "app_registry" {
  provider      = google
  location      = var.region
  repository_id = var.repo_name
  description   = "Container registry for Code2Cloud"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifact_registry]
}

# VPC Network Creation
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

# Subnet Creation
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${google_compute_network.vpc_network.name}-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.name

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }

}

# Cluster Creation
resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false # 👈 set to false

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  node_config {
    machine_type = "e2-medium"
    tags         = ["gke-node"]
    disk_type    = "pd-standard" # ✅ use standard disks
    disk_size_gb = 50            # SSD disk size per node
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    # By default, this creates SSD persistent disks
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

}

# data "google_container_cluster" "gke_data" {
#   name     = google_container_cluster.gke_cluster.name
#   location = google_container_cluster.gke_cluster.location
# }

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}

# Node Pool Creation
resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.gke_cluster.name
  location   = google_container_cluster.gke_cluster.location
  name       = "${google_container_cluster.gke_cluster.name}-nodes"
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    tags         = ["gke-node"]
    disk_type    = "pd-standard" # ✅ use standard disks
    disk_size_gb = 50            # Minimum disk size per node
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [google_container_cluster.gke_cluster]
}

# Firewall Creation
resource "google_compute_firewall" "allow_internal" {
  name    = "${google_compute_network.vpc_network.name}-firewall"
  network = google_compute_network.vpc_network.name

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8000", "5000"]
  }

  target_tags = ["gke-node"]
}

# Kubernetes service data
data "kubernetes_service" "multi_port_service" {
  metadata {
    name      = "multi-port-service"
    namespace = "default"
  }

  depends_on = [helm_release.my_app]
}

locals {

  repo_name   = google_artifact_registry_repository.app_registry.repository_id
  api_image   = "${var.region}-docker.pkg.dev/${var.project_id}/${local.repo_name}/backend:latest"
  ui_image    = "${var.region}-docker.pkg.dev/${var.project_id}/${local.repo_name}/frontend:latest"
  external_ip = data.kubernetes_service.multi_port_service.status[0].load_balancer[0].ingress[0].ip

}

resource "helm_release" "my_app" {

  name  = "c2c-app"
  chart = "../helm" # local path to your Helm chart

  values = [
    yamlencode({
      api = {
        image = local.api_image
      }
      ui = {
        image = local.ui_image
      }
    })
  ]
}

output "service_urls" {
  value = {
    API = "http://${local.external_ip}:8000"
    UI  = "http://${local.external_ip}:5000"
  }
}

