locals {
  own_ranges = values(var.cidrs)
  range_pairs = concat(
    [for p in setproduct(local.own_ranges, local.own_ranges) : p if index(local.own_ranges, p[0]) < index(local.own_ranges, p[1])],
    [for p in setproduct(local.own_ranges, tolist(var.aws_cidrs)) : p]
  )
}
resource "google_compute_network" "this" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  lifecycle {
    prevent_destroy = true
    precondition {
      condition = length(toset(local.own_ranges)) == 4 && alltrue([for p in local.range_pairs :
        cidrhost("${cidrhost(p[0], 0)}/${min(tonumber(split("/", p[0])[1]), tonumber(split("/", p[1])[1]))}", 0) !=
        cidrhost("${cidrhost(p[1], 0)}/${min(tonumber(split("/", p[0])[1]), tonumber(split("/", p[1])[1]))}", 0)
      ])
      error_message = "Node/Pod/Service/SQL ranges must be distinct and not overlap each other or AWS."
    }
  }
}
resource "google_compute_subnetwork" "this" {
  name                     = "${local.name}-app-subnet"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.cidrs.nodes
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "${local.name}-pods"
    ip_cidr_range = var.cidrs.pods
  }
  secondary_ip_range {
    range_name    = "${local.name}-services"
    ip_cidr_range = var.cidrs.services
  }
  lifecycle { prevent_destroy = true }
}
resource "google_compute_global_address" "sql" {
  name          = "${local.name}-sql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = cidrhost(var.cidrs.sql, 0)
  prefix_length = tonumber(split("/", var.cidrs.sql)[1])
  network       = google_compute_network.this.id
  lifecycle { prevent_destroy = true }
}
resource "google_service_networking_connection" "sql" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql.name]
  deletion_policy         = "ABANDON"
  lifecycle { prevent_destroy = true }
}
resource "google_compute_network_peering_routes_config" "sql" {
  network              = google_compute_network.this.name
  peering              = google_service_networking_connection.sql.peering
  export_custom_routes = true
  import_custom_routes = false
}
resource "google_compute_ha_vpn_gateway" "this" {
  name    = "${local.name}-vpn"
  region  = var.region
  network = google_compute_network.this.id
  lifecycle { prevent_destroy = true }
}
resource "google_compute_router" "this" {
  name    = "${local.name}-router"
  region  = var.region
  network = google_compute_network.this.id
  bgp {
    asn               = var.router_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges { range = var.cidrs.sql }
  }
  lifecycle { prevent_destroy = true }
}
resource "google_compute_router_nat" "nodes" {
  name                               = "${local.name}-nat"
  region                             = var.region
  router                             = google_compute_router.this.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.this.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
output "network" {
  value = {
    id                  = google_compute_network.this.id
    subnetwork_id       = google_compute_subnetwork.this.id
    pods_range_name     = "${local.name}-pods"
    services_range_name = "${local.name}-services"
    sql_range_name      = google_compute_global_address.sql.name
    cidrs               = var.cidrs
  }
  depends_on = [google_service_networking_connection.sql, google_compute_network_peering_routes_config.sql, google_compute_router_nat.nodes]
}
output "gcp_peer" {
  # Interface IDs, not response ordering, identify the approved AWS attachment.
  value = { gateway_ip = one([for i in google_compute_ha_vpn_gateway.this.vpn_interfaces : i.ip_address if i.id == 0]), asn = var.router_asn }
}
output "vpn_foundation" {
  value = { gateway_id = google_compute_ha_vpn_gateway.this.id, router_name = google_compute_router.this.name, asn = var.router_asn }
}
