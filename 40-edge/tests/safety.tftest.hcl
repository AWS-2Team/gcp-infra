mock_provider "google" {
  mock_resource "google_certificate_manager_dns_authorization" {
    override_during = plan
    defaults        = { dns_resource_record = [{ name = "_acme.example.com.", type = "CNAME", data = "example.authorize.certificatemanager.goog." }] }
  }
}
variables {
  project_id = "example-dr-project"
  region     = "asia-northeast3"
  project    = "last-lab"
  env        = "dev"
  domains    = ["app.example.com"]
}
run "external_dns_contract" {
  command = plan
  assert {
    condition     = google_compute_global_address.gateway.name == "last-lab-dev-dr-gateway-ip" && length(google_dns_record_set.authorization) == 0 && length(google_certificate_manager_certificate_map_entry.this) == 1
    error_message = "External DNS uses an output contract without taking over traffic records."
  }
}
run "cloud_dns_authorization_only" {
  command = plan
  variables { dns_zone = { name = "public-example", project_id = "example-dr-project" } }
  assert {
    condition     = length(google_dns_record_set.authorization) == 1 && google_dns_record_set.authorization["app.example.com"].type == "CNAME"
    error_message = "Only certificate CNAME verification is Terraform-owned."
  }
}
