resource "google_compute_external_vpn_gateway" "aws" {
  project         = var.project_id
  name            = "${var.name}-aws-peer"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  dynamic "interface" {
    for_each = var.tunnels
    content {
      id         = tonumber(interface.key)
      ip_address = interface.value.external_ip
    }
  }
}

resource "google_compute_vpn_tunnel" "this" {
  for_each    = var.tunnels
  project     = var.project_id
  region      = var.region
  name        = "${var.name}-aws-${each.key}"
  vpn_gateway = var.vpn_gateway_id
  # ponytail: 두 터널이 인터페이스 0을 공유합니다. GCP 이중화가 필요하면 두 번째 AWS 연결과 터널을 추가합니다.
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.aws.id
  peer_external_gateway_interface = tonumber(each.key)
  router                          = var.router_id
  ike_version                     = 2
  shared_secret_wo                = var.shared_secrets[each.key]
  shared_secret_wo_version        = each.value.secret_version
}

resource "google_compute_router_interface" "this" {
  for_each   = var.tunnels
  project    = var.project_id
  region     = var.region
  name       = "aws-interface-${each.key}"
  router     = var.router_name
  vpn_tunnel = google_compute_vpn_tunnel.this[each.key].name
  ip_range   = each.value.gcp_bgp_cidr
}

resource "google_compute_router_peer" "this" {
  for_each                  = var.tunnels
  project                   = var.project_id
  region                    = var.region
  name                      = "aws-peer-${each.key}"
  router                    = var.router_name
  interface                 = google_compute_router_interface.this[each.key].name
  peer_ip_address           = each.value.aws_bgp_ip
  peer_asn                  = var.peer_asn
  advertised_route_priority = var.advertised_route_priority
}
