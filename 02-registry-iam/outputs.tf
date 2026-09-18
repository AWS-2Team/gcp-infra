output "cloud_run_service_account" {
  description = "Cloud Run App 배포에서 사용할 실행 계정 이메일"
  value       = google_service_account.cloud_run.email
}

output "cloud_run_web_service_account" {
  description = "Cloud Run Web 배포에서 사용할 실행 계정 이메일"
  value       = google_service_account.cloud_run_web.email
}

output "artifact_registry_url" {
  description = "App 이미지 업로드에 사용할 저장소 경로"
  value       = "${google_artifact_registry_repository.app.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}

output "artifact_registry_web_url" {
  description = "Web 이미지 업로드에 사용할 저장소 경로"
  value       = "${google_artifact_registry_repository.web.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.web.repository_id}"
}
