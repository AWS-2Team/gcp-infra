mock_provider "google" {}

variables {
  project_id                        = "example-project"
  region                            = "asia-northeast3"
  project                           = "last-lab"
  env                               = "dev"
  cloud_run_account_id              = "last-lab-dev-run"
  cloud_run_display_name            = "App 실행 계정"
  cloud_run_web_display_name        = "Web 실행 계정"
  artifact_registry_suffix          = "images"
  artifact_registry_web_suffix      = "web-images"
  artifact_registry_format          = "DOCKER"
  artifact_registry_description     = "App 이미지"
  artifact_registry_web_description = "Web 이미지"
}

run "create_from_empty_state" {
  command = plan

  assert {
    condition = (
      google_service_account.cloud_run.account_id == "last-lab-dev-run" &&
      google_service_account.cloud_run_web.account_id == "last-lab-dev-dr-web" &&
      google_project_iam_member.cloud_sql_client.role == "roles/cloudsql.client" &&
      google_artifact_registry_repository.app.repository_id == "last-lab-dev-dr-images" &&
      google_artifact_registry_repository.web.repository_id == "last-lab-dev-dr-web-images"
    )
    error_message = "빈 State에서 App/Web 계정과 저장소, App의 Cloud SQL 연결 권한을 구성해야 합니다."
  }
}
