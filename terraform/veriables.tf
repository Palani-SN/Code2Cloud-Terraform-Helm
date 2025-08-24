# variables.tf
variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "repo_name" {
  default = "c2c-artifacts"
}
variable "cluster_name" {
  default = "c2c-cluster"
}
variable "network_name" {
  default = "c2c-network"
}
variable "app_name" {
  default = "c2c-app"
}
