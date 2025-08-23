# variables.tf
variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "cluster_name" {
  default = "my-gke-cluster"
}
