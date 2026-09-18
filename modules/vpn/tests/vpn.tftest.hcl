mock_provider "google" {}

variables {
  project_id                = "kdt4-2-506106"
  region                    = "asia-northeast3"
  name                      = "last-lab-dev-dr"
  vpn_gateway_id            = "projects/kdt4-2-506106/regions/asia-northeast3/vpnGateways/last-lab-dev-dr-vpn"
  router_id                 = "projects/kdt4-2-506106/regions/asia-northeast3/routers/last-lab-dev-dr-router"
  router_name               = "last-lab-dev-dr-router"
  peer_asn                  = 64512
  advertised_route_priority = 100
  # 문서용 IP와 모의 키입니다. 모의 프로바이더는 Google API를 호출하지 않습니다.
  tunnels = {
    "0" = { external_ip = "203.0.113.10", gcp_bgp_cidr = "169.254.10.2/30", aws_bgp_ip = "169.254.10.1", secret_version = "1" }
    "1" = { external_ip = "203.0.113.11", gcp_bgp_cidr = "169.254.11.2/30", aws_bgp_ip = "169.254.11.1", secret_version = "1" }
  }
  shared_secrets = { "0" = "test-key-0", "1" = "test-key-1" }
}

run "two_tunnels_on_one_gcp_interface" {
  command = plan
  assert {
    condition = (
      google_compute_external_vpn_gateway.aws.name == "last-lab-dev-dr-aws-peer" &&
      google_compute_vpn_tunnel.this["0"].name == "last-lab-dev-dr-aws-0" &&
      google_compute_vpn_tunnel.this["1"].name == "last-lab-dev-dr-aws-1"
    )
    error_message = "모듈 입력을 name으로 통일해도 기존 Gateway와 터널 이름을 보존해야 합니다."
  }
  assert {
    condition     = length(google_compute_vpn_tunnel.this) == 2 && length(google_compute_router_interface.this) == 2 && length(google_compute_router_peer.this) == 2
    error_message = "터널 2개에 각각 라우터 인터페이스와 BGP 피어가 필요합니다."
  }
  assert {
    condition     = google_compute_external_vpn_gateway.aws.redundancy_type == "TWO_IPS_REDUNDANCY" && length(google_compute_external_vpn_gateway.aws.interface) == 2
    error_message = "AWS 연결 하나의 외부 IP 두 개만 등록해야 합니다."
  }
  assert {
    condition = (
      google_compute_vpn_tunnel.this["0"].vpn_gateway_interface == 0 &&
      google_compute_vpn_tunnel.this["1"].vpn_gateway_interface == 0 &&
      alltrue([for key, tunnel in google_compute_vpn_tunnel.this : tunnel.peer_external_gateway_interface == tonumber(key) && tunnel.ike_version == 2])
    )
    error_message = "두 터널 모두 IKEv2를 사용하고 GCP 인터페이스 0에 연결돼야 합니다."
  }
}

run "reject_unassigned_aws_endpoints" {
  command = plan
  variables { tunnels = {} }
  expect_failures = [var.tunnels]
}

run "reject_duplicate_inside_ranges" {
  command = plan
  variables {
    tunnels = {
      "0" = { external_ip = "203.0.113.10", gcp_bgp_cidr = "169.254.10.2/30", aws_bgp_ip = "169.254.10.1", secret_version = "1" }
      "1" = { external_ip = "203.0.113.11", gcp_bgp_cidr = "169.254.10.2/30", aws_bgp_ip = "169.254.10.1", secret_version = "1" }
    }
  }
  expect_failures = [var.tunnels]
}

run "reject_four_tunnel_inputs" {
  command = plan
  variables {
    tunnels = {
      "0" = { external_ip = "203.0.113.10", gcp_bgp_cidr = "169.254.10.2/30", aws_bgp_ip = "169.254.10.1", secret_version = "1" }
      "1" = { external_ip = "203.0.113.11", gcp_bgp_cidr = "169.254.11.2/30", aws_bgp_ip = "169.254.11.1", secret_version = "1" }
      "2" = { external_ip = "203.0.113.12", gcp_bgp_cidr = "169.254.12.2/30", aws_bgp_ip = "169.254.12.1", secret_version = "1" }
      "3" = { external_ip = "203.0.113.13", gcp_bgp_cidr = "169.254.13.2/30", aws_bgp_ip = "169.254.13.1", secret_version = "1" }
    }
    shared_secrets = { "0" = "test-key-0", "1" = "test-key-1", "2" = "test-key-2", "3" = "test-key-3" }
  }
  expect_failures = [var.tunnels, var.shared_secrets]
}
