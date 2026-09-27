mock_provider "google" {}
variables {
  project_id          = "example-dr-project"
  region              = "asia-northeast3"
  project             = "last-lab"
  env                 = "dev"
  state_bucket_name   = "example-unique-test-state"
  state_location      = "ASIA-NORTHEAST3"
  state_admin_members = ["user:test@example.com"]
  log_retention_days  = 30
}
run "protected_bucket_and_retained_services" {
  command = plan
  assert {
    condition     = google_storage_bucket.state.force_destroy == false && google_storage_bucket.state.uniform_bucket_level_access && google_storage_bucket.state.public_access_prevention == "enforced" && google_storage_bucket.state.versioning[0].enabled
    error_message = "State must remain private, versioned and not force-deleted."
  }
  assert {
    condition     = alltrue([for s in google_project_service.required : !s.disable_on_destroy])
    error_message = "Removing bootstrap must not disable project APIs."
  }
}
