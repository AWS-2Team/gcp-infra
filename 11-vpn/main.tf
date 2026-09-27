locals { interface_ids = { tunnel1 = 0, tunnel2 = 1 } }
resource "google_compute_external_vpn_gateway" "aws" {
  name            = "${local.name}-aws-peer"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  dynamic "interface" {
    for_each = var.aws_peer.tunnels
    content {
      id         = local.interface_ids[interface.key]
      ip_address = interface.value.external_ip
    }
  }
}
resource "google_compute_vpn_tunnel" "this" {
  for_each    = var.aws_peer.tunnels
  name        = "${local.name}-aws-${each.key}"
  region      = var.region
  vpn_gateway = var.vpn_foundation.gateway_id
  # Both tunnels intentionally use GCP interface 0; this is not full HA across interfaces.
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.aws.id
  peer_external_gateway_interface = local.interface_ids[each.key]
  router                          = var.vpn_foundation.router_name
  ike_version                     = 2
  shared_secret_wo                = var.shared_secrets[each.key]
  shared_secret_wo_version        = var.secret_versions[each.key]
}
resource "google_compute_router_interface" "this" {
  for_each   = var.aws_peer.tunnels
  name       = "${local.name}-aws-${each.key}"
  region     = var.region
  router     = var.vpn_foundation.router_name
  vpn_tunnel = google_compute_vpn_tunnel.this[each.key].name
  ip_range   = each.value.gcp_bgp_cidr
}
resource "google_compute_router_peer" "this" {
  for_each                  = var.aws_peer.tunnels
  name                      = "${local.name}-aws-${each.key}"
  region                    = var.region
  router                    = var.vpn_foundation.router_name
  interface                 = google_compute_router_interface.this[each.key].name
  peer_ip_address           = each.value.aws_bgp_ip
  peer_asn                  = var.aws_peer.aws_asn
  advertised_route_priority = var.route_priority
}
output "tunnel_names" { value = { for k, v in google_compute_vpn_tunnel.this : k => v.name } }
