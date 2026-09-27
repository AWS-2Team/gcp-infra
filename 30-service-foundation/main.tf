resource "google_artifact_registry_repository" "this" {
  for_each      = var.repositories
  location      = var.region
  repository_id = "${local.name}-${each.key}-images"
  format        = "DOCKER"
  lifecycle { prevent_destroy = true }
}
resource "google_secret_manager_secret" "this" {
  for_each  = var.secret_names
  secret_id = "${local.name}-${each.key}"
  replication {
    auto {}
  }
  lifecycle { prevent_destroy = true }
}
resource "google_service_account" "this" {
  for_each     = var.services
  account_id   = each.value.account_id
  display_name = "${local.name} ${each.key}"
}
resource "google_service_account_iam_member" "workload" {
  for_each           = var.services
  service_account_id = google_service_account.this[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}
locals {
  sql_roles     = { for p in setproduct([for k, s in var.services : k if s.cloud_sql_access], ["roles/cloudsql.client", "roles/cloudsql.instanceUser"]) : "${p[0]}/${p[1]}" => { service = p[0], role = p[1] } }
  secret_access = merge({}, [for k, s in var.services : { for n in s.secret_names : "${k}/${n}" => { service = k, secret = n } }]...)
  writers       = merge({}, [for k, members in var.image_writer_members : { for m in members : "${k}/${m}" => { repository = k, member = m } }]...)
}
resource "google_project_iam_member" "sql" {
  for_each = local.sql_roles
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.this[each.value.service].email}"
}
resource "google_secret_manager_secret_iam_member" "reader" {
  for_each  = local.secret_access
  secret_id = google_secret_manager_secret.this[each.value.secret].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.this[each.value.service].email}"
}
resource "google_artifact_registry_repository_iam_member" "writer" {
  for_each   = local.writers
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.this[each.value.repository].name
  role       = "roles/artifactregistry.writer"
  member     = each.value.member
}
output "repositories" { value = { for k, r in google_artifact_registry_repository.this : k => "${var.region}-docker.pkg.dev/${var.project_id}/${r.repository_id}" } }
output "service_accounts" { value = { for k, s in google_service_account.this : k => s.email } }
output "secrets" { value = { for k, s in google_secret_manager_secret.this : k => s.secret_id } }
