mock_provider "google" {}
variables {
  project_id           = "example-dr-project"
  region               = "asia-northeast3"
  project              = "last-lab"
  env                  = "dev"
  repositories         = ["orders", "retired"]
  secret_names         = ["orders-config"]
  services             = { orders = { account_id = "last-lab-dev-dr-orders", namespace = "orders", kubernetes_service_account = "app", cloud_sql_access = true, secret_names = ["orders-config"] } }
  image_writer_members = { orders = ["user:builder@example.com"] }
}
run "scoped_identity_and_retained_artifacts" {
  command = plan
  assert {
    condition     = length(google_artifact_registry_repository.this) == 2 && length(google_service_account.this) == 1 && length(google_secret_manager_secret.this) == 1
    error_message = "Retired service repositories remain independent of active identities."
  }
  assert {
    condition     = google_service_account_iam_member.workload["orders"].member == "serviceAccount:example-dr-project.svc.id.goog[orders/app]" && length(google_project_iam_member.sql) == 2
    error_message = "Only the selected namespace/service account gets the service identity."
  }
}
run "no_services_keeps_data_and_images" {
  command = plan
  variables { services = {} }
  assert {
    condition     = length(google_artifact_registry_repository.this) == 2 && length(google_secret_manager_secret.this) == 1 && length(google_service_account.this) == 0
    error_message = "Disabling service identities must preserve artifacts and secret metadata."
  }
}
run "reject_overlength_account_id" {
  command = plan
  variables { services = { orders = { account_id = "last-lab-dev-dr-account-name-that-is-too-long", namespace = "orders", kubernetes_service_account = "app", cloud_sql_access = false, secret_names = [] } } }
  expect_failures = [var.services]
}
