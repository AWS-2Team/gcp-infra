locals {
  name_prefix = "${var.project}-${var.env}-dr"
}

# 필요한 API는 먼저 적용하는 00-network에서 활성화합니다.
resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = var.cloud_run_account_id
  display_name = var.cloud_run_display_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "cloud_run_web" {
  project      = var.project_id
  account_id   = "${local.name_prefix}-web"
  display_name = var.cloud_run_web_display_name

  lifecycle {
    prevent_destroy = true
  }
}

# App 실행 계정에 Cloud SQL 연결 권한을 부여합니다. DB 로그인과 SQL 권한은 별도로 설정합니다.
resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = google_service_account.cloud_run.member
}

resource "google_artifact_registry_repository" "app" {
  project       = var.project_id
  location      = var.region
  repository_id = "${local.name_prefix}-${var.artifact_registry_suffix}"
  format        = var.artifact_registry_format
  description   = var.artifact_registry_description

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_artifact_registry_repository" "web" {
  project       = var.project_id
  location      = var.region
  repository_id = "${local.name_prefix}-${var.artifact_registry_web_suffix}"
  format        = var.artifact_registry_format
  description   = var.artifact_registry_web_description

  lifecycle {
    prevent_destroy = true
  }
}
