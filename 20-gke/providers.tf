provider "google" {
  project = var.project_id
  region  = var.region
  default_labels = {
    project     = var.project
    environment = var.env
    role        = "dr"
    managed_by  = "terraform"
  }
}
locals {
  name = "${var.project}-${var.env}-dr"
}
