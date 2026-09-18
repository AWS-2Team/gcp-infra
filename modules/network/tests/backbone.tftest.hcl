mock_provider "google" {}

variables {
  project_id               = "kdt4-2-506106"
  region                   = "asia-northeast3"
  name                     = "last-lab-dev-dr"
  psa_cidr                 = "10.30.0.0/16"
  router_asn               = 64514
  subnet_cidr              = "10.20.0.0/26"
  routing_mode             = "REGIONAL"
  private_ip_google_access = true
}

run "private_sql_route_contract" {
  command = plan
  assert {
    condition = (
      google_compute_network.this.name == "last-lab-dev-dr-vpc" &&
      google_compute_subnetwork.this.name == "last-lab-dev-dr-subnet" &&
      google_compute_global_address.psa.name == "last-lab-dev-dr-psa" &&
      google_compute_ha_vpn_gateway.this.name == "last-lab-dev-dr-vpn" &&
      google_compute_router.this.name == "last-lab-dev-dr-router"
    )
    error_message = "모듈 입력을 name으로 통일해도 기존 리소스 이름을 보존해야 합니다."
  }
  assert {
    condition     = google_compute_network.this.auto_create_subnetworks == false
    error_message = "백본에서 자동 서브넷을 생성하면 안 됩니다."
  }
  assert {
    condition     = google_compute_network_peering_routes_config.psa.export_custom_routes && !google_compute_network_peering_routes_config.psa.import_custom_routes
    error_message = "PSA 연결에 AWS에서 학습한 사용자 지정 경로를 전달해야 합니다."
  }
  assert {
    condition     = toset([for r in google_compute_router.this.bgp[0].advertised_ip_ranges : r.range]) == toset([var.psa_cidr])
    error_message = "Cloud Router에서 Cloud SQL 예약 대역을 광고해야 합니다."
  }
}

run "reject_overlapping_subnet_and_psa" {
  command = plan
  variables {
    subnet_cidr = "10.30.1.0/26"
  }
  expect_failures = [google_compute_subnetwork.this]
}
