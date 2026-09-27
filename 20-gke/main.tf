resource "google_service_account" "nodes" {
  account_id   = "${local.name}-nodes"
  display_name = "${local.name} GKE nodes"
}
resource "google_project_iam_member" "nodes" {
  for_each = toset(["roles/container.defaultNodeServiceAccount", "roles/artifactregistry.reader"])
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.nodes.email}"
}
resource "google_container_cluster" "this" {
  name                     = "${local.name}-gke"
  location                 = var.location
  network                  = var.network.id
  subnetwork               = var.network.subnetwork_id
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = true
  networking_mode          = "VPC_NATIVE"
  datapath_provider        = "ADVANCED_DATAPATH"
  enable_shielded_nodes    = true
  node_config {
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  private_cluster_config { enable_private_nodes = true }
  control_plane_endpoints_config {
    dns_endpoint_config { allow_external_traffic = true }
    ip_endpoints_config { enabled = false }
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = var.network.pods_range_name
    services_secondary_range_name = var.network.services_range_name
  }
  workload_identity_config { workload_pool = "${var.project_id}.svc.id.goog" }
  release_channel { channel = var.release_channel }
  gateway_api_config { channel = "CHANNEL_STANDARD" }
  secret_manager_config { enabled = true }
  logging_config { enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"] }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus { enabled = true }
  }
  maintenance_policy {
    daily_maintenance_window { start_time = var.maintenance_start_utc }
  }
  lifecycle { prevent_destroy = true }
  depends_on = [google_project_iam_member.nodes]
}
resource "google_container_node_pool" "this" {
  for_each           = var.node_pools
  name               = "${local.name}-${each.key}"
  location           = var.location
  cluster            = google_container_cluster.this.name
  node_locations     = each.value.zones
  initial_node_count = each.value.initial_nodes
  autoscaling {
    total_min_node_count = each.value.min_nodes
    total_max_node_count = each.value.max_nodes
    location_policy      = "BALANCED"
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = "pd-balanced"
    image_type      = "COS_CONTAINERD"
    spot            = each.value.spot
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata        = { disable-legacy-endpoints = "true" }
    workload_metadata_config { mode = "GKE_METADATA" }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
  lifecycle { ignore_changes = [initial_node_count] }
}
output "cluster" {
  value = { name = google_container_cluster.this.name, location = var.location, project_id = var.project_id, workload_pool = "${var.project_id}.svc.id.goog" }
}
