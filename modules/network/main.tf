resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  region                   = var.region
  name                     = "${var.name}-subnet"
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = var.private_ip_google_access
  lifecycle {
    prevent_destroy = true
    precondition {
      condition = (
        cidrhost("${cidrhost(var.subnet_cidr, 0)}/${min(tonumber(split("/", var.subnet_cidr)[1]), tonumber(split("/", var.psa_cidr)[1]))}", 0) !=
        cidrhost("${cidrhost(var.psa_cidr, 0)}/${min(tonumber(split("/", var.subnet_cidr)[1]), tonumber(split("/", var.psa_cidr)[1]))}", 0)
      )
      error_message = "서브넷과 PSA의 CIDR은 겹치면 안 됩니다. 적용 전 AWS와 다른 GCP 대역의 중복 여부도 확인하세요."
    }
  }
}

resource "google_compute_global_address" "psa" {
  project       = var.project_id
  name          = "${var.name}-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = cidrhost(var.psa_cidr, 0)
  prefix_length = tonumber(split("/", var.psa_cidr)[1])
  network       = google_compute_network.this.id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_network_peering_routes_config" "psa" {
  project              = var.project_id
  network              = google_compute_network.this.name
  peering              = google_service_networking_connection.psa.peering
  export_custom_routes = true
  import_custom_routes = false
}

resource "google_compute_ha_vpn_gateway" "this" {
  project = var.project_id
  region  = var.region
  name    = "${var.name}-vpn"
  network = google_compute_network.this.id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_router" "this" {
  project = var.project_id
  region  = var.region
  name    = "${var.name}-router"
  network = google_compute_network.this.id
  bgp {
    asn               = var.router_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = var.psa_cidr
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
