mock_provider "google" {}
variables {
  project_id     = "example-dr-project"
  region         = "asia-northeast3"
  project        = "last-lab"
  env            = "dev"
  vpn_foundation = { gateway_id = "projects/example-dr-project/regions/asia-northeast3/vpnGateways/test", router_name = "last-lab-dev-dr-router", asn = 64514 }
  aws_peer = {
    aws_asn = 64512
    tunnels = {
      tunnel1 = { external_ip = "192.0.2.1", aws_bgp_ip = "169.254.10.1", gcp_bgp_cidr = "169.254.10.2/30", psk_secret_arn = "arn:aws:secretsmanager:ap-northeast-2:123456789012:secret:example" }
      tunnel2 = { external_ip = "192.0.2.2", aws_bgp_ip = "169.254.11.1", gcp_bgp_cidr = "169.254.11.2/30", psk_secret_arn = "arn:aws:secretsmanager:ap-northeast-2:123456789012:secret:example" }
    }
  }
  shared_secrets  = { tunnel1 = "mock-only-secret-one", tunnel2 = "mock-only-secret-two" }
  secret_versions = { tunnel1 = 1, tunnel2 = 1 }
}
run "two_tunnels_without_router_ownership" {
  command = plan
  assert {
    condition     = length(google_compute_vpn_tunnel.this) == 2 && alltrue([for t in google_compute_vpn_tunnel.this : t.vpn_gateway_interface == 0 && t.ike_version == 2 && t.shared_secret_wo_version == "1"])
    error_message = "The approved topology has two IKEv2 tunnels on GCP interface zero."
  }
  assert {
    condition     = google_compute_router_interface.this["tunnel1"].ip_range == "169.254.10.2/30" && google_compute_router_peer.this["tunnel1"].peer_ip_address == "169.254.10.1" && google_compute_router_peer.this["tunnel2"].peer_asn == 64512
    error_message = "AWS inside address must be peer, not the GCP local interface."
  }
}
run "reject_missing_key_version" {
  command = plan
  variables { secret_versions = { tunnel1 = 1 } }
  expect_failures = [var.secret_versions]
}
