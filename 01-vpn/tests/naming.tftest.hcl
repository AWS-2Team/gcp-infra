mock_provider "google" {
  mock_data "google_compute_router" {
    defaults = {
      bgp = [{ asn = 64514 }]
    }
  }
}

variables {
  project_id                = "example-project"
  project                   = "last-lab"
  env                       = "dev"
  region                    = "asia-northeast3"
  peer_asn                  = 64512
  advertised_route_priority = 100
  tunnels = {
    "0" = { external_ip = "203.0.113.10", gcp_bgp_cidr = "169.254.10.2/30", aws_bgp_ip = "169.254.10.1", secret_version = "1" }
    "1" = { external_ip = "203.0.113.11", gcp_bgp_cidr = "169.254.11.2/30", aws_bgp_ip = "169.254.11.1", secret_version = "1" }
  }
  shared_secrets = { "0" = "test-key-0", "1" = "test-key-1" }
}

run "preserve_existing_names_and_lookups" {
  command = plan
  assert {
    condition = (
      data.google_compute_ha_vpn_gateway.this.name == "last-lab-dev-dr-vpn" &&
      data.google_compute_router.this.name == "last-lab-dev-dr-router" &&
      output.tunnel_names["0"] == "last-lab-dev-dr-aws-0" &&
      output.tunnel_names["1"] == "last-lab-dev-dr-aws-1" &&
      output.bgp_peer_names["0"] == "aws-peer-0" &&
      output.bgp_peer_names["1"] == "aws-peer-1"
    )
    error_message = "기존 Gateway/Router 조회 이름과 터널/BGP 피어 이름을 보존해야 합니다."
  }
}
