mock_provider "google" {}
variables {
  project_id            = "example-dr-project"
  region                = "asia-northeast3"
  project               = "last-lab"
  env                   = "dev"
  network               = { id = "projects/example-dr-project/global/networks/test", subnetwork_id = "projects/example-dr-project/regions/asia-northeast3/subnetworks/test", pods_range_name = "pods", services_range_name = "services" }
  location              = "asia-northeast3-a"
  maintenance_start_utc = "18:00"
  node_pools            = { general = { machine_type = "e2-standard-2", disk_size_gb = 30, initial_nodes = 1, min_nodes = 1, max_nodes = 2, zones = ["asia-northeast3-a"], spot = false } }
}
run "private_cluster_identity_and_total_capacity" {
  command = plan
  assert {
    condition     = google_container_cluster.this.deletion_protection && google_container_cluster.this.private_cluster_config[0].enable_private_nodes && !google_container_cluster.this.control_plane_endpoints_config[0].ip_endpoints_config[0].enabled
    error_message = "Nodes must be private and direct control-plane IP access disabled."
  }
  assert {
    condition     = google_container_cluster.this.workload_identity_config[0].workload_pool == "example-dr-project.svc.id.goog" && google_container_cluster.this.gateway_api_config[0].channel == "CHANNEL_STANDARD" && google_container_cluster.this.secret_manager_config[0].enabled
    error_message = "Workload identity, Gateway and secret mounting are required platform contracts."
  }
  assert {
    condition     = google_container_node_pool.this["general"].autoscaling[0].total_max_node_count == 2
    error_message = "Capacity must use a total bound rather than a per-zone bound."
  }
}
run "reject_capacity_below_initial_nodes" {
  command = plan
  variables { node_pools = { general = { machine_type = "e2-standard-2", disk_size_gb = 30, initial_nodes = 2, min_nodes = 1, max_nodes = 2, zones = ["asia-northeast3-a", "asia-northeast3-b"], spot = false } } }
  expect_failures = [var.node_pools]
}
