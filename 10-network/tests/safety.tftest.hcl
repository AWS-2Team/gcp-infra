mock_provider "google" {}
variables {
  project_id = "example-dr-project"
  region     = "asia-northeast3"
  project    = "last-lab"
  env        = "dev"
  cidrs      = { nodes = "10.80.0.0/24", pods = "10.81.0.0/20", services = "10.82.0.0/24", sql = "10.83.0.0/16" }
  aws_cidrs  = ["10.0.0.0/16"]
  router_asn = 64514
}
run "private_network_and_sql_return_routes" {
  command = plan
  assert {
    condition     = google_compute_network.this.name == "last-lab-dev-dr-vpc" && google_compute_subnetwork.this.private_ip_google_access && length(google_compute_subnetwork.this.secondary_ip_range) == 2
    error_message = "GKE needs private node access and separate Pod/Service ranges."
  }
  assert {
    condition     = google_compute_network_peering_routes_config.sql.export_custom_routes && !google_compute_network_peering_routes_config.sql.import_custom_routes && google_compute_router.this.bgp[0].advertise_mode == "CUSTOM"
    error_message = "SQL peering must learn AWS return routes and advertise SQL range."
  }
}
run "reject_aws_overlap" {
  command = plan
  variables { aws_cidrs = ["10.80.0.0/16"] }
  expect_failures = [google_compute_network.this]
}
run "reject_internal_overlap" {
  command = plan
  variables { cidrs = { nodes = "10.80.0.0/24", pods = "10.80.0.0/20", services = "10.82.0.0/24", sql = "10.83.0.0/16" } }
  expect_failures = [google_compute_network.this]
}

run "reject_asn_outside_aws_contract" {
  command = plan
  variables { router_asn = 4200000000 }
  expect_failures = [var.router_asn]
}
