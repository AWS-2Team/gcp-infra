# This root intentionally uses local State. Back it up securely after every apply.
resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com", "container.googleapis.com", "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com", "iam.googleapis.com", "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com", "secretmanager.googleapis.com", "sts.googleapis.com",
    "certificatemanager.googleapis.com", "dns.googleapis.com", "monitoring.googleapis.com",
    "logging.googleapis.com", "storage.googleapis.com", "cloudresourcemanager.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
resource "google_storage_bucket" "state" {
  project                     = var.project_id
  name                        = var.state_bucket_name
  location                    = var.state_location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  versioning { enabled = true }
  lifecycle { prevent_destroy = true }
  depends_on = [google_project_service.required]
}
resource "google_storage_bucket_iam_member" "state_admin" {
  for_each = var.state_admin_members
  bucket   = google_storage_bucket.state.name
  role     = "roles/storage.objectAdmin"
  member   = each.key
}
resource "google_logging_project_bucket_config" "default" {
  project        = var.project_id
  location       = "global"
  bucket_id      = "_Default"
  retention_days = var.log_retention_days
  depends_on     = [google_project_service.required]
}
output "state_bucket" { value = google_storage_bucket.state.name }
