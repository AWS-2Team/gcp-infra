locals {
  # 기존 DR 리소스 이름을 보존합니다.
  name_prefix = "${var.project}-${var.env}-dr"
}

# 필요한 리소스 두 개만 조회하며 다른 계층의 전체 상태 파일은 읽지 않습니다.
data "google_compute_ha_vpn_gateway" "this" {
  project = var.project_id
  region  = var.region
  name    = "${local.name_prefix}-vpn"
}

data "google_compute_router" "this" {
  project = var.project_id
  region  = var.region
  name    = "${local.name_prefix}-router"
  network = data.google_compute_ha_vpn_gateway.this.network
  lifecycle {
    postcondition {
      condition     = self.bgp[0].asn != var.peer_asn
      error_message = "GCP와 AWS의 BGP ASN은 서로 달라야 합니다."
    }
  }
}

module "vpn" {
  source                    = "../modules/vpn"
  project_id                = var.project_id
  region                    = var.region
  name                      = local.name_prefix
  vpn_gateway_id            = data.google_compute_ha_vpn_gateway.this.id
  router_id                 = data.google_compute_router.this.id
  router_name               = data.google_compute_router.this.name
  tunnels                   = var.tunnels
  peer_asn                  = var.peer_asn
  advertised_route_priority = var.advertised_route_priority
  shared_secrets            = var.shared_secrets
}
