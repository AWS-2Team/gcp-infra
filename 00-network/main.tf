locals {
  # 기존 DR 리소스 이름을 보존합니다.
  name_prefix = "${var.project}-${var.env}-dr"
}

resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "datamigration.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "backbone" {
  source                   = "../modules/network"
  project_id               = var.project_id
  region                   = var.region
  name                     = local.name_prefix
  psa_cidr                 = var.psa_cidr
  router_asn               = var.router_asn
  subnet_cidr              = var.subnet_cidr
  routing_mode             = var.routing_mode
  private_ip_google_access = var.private_ip_google_access
  depends_on               = [google_project_service.required]
}
