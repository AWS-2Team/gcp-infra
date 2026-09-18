provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    environment = var.env
    project     = var.project
    managed_by  = "terraform"
  }
}
