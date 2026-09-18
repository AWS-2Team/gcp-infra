mock_provider "google" {}

variables {
  project_id               = "example-project"
  project                  = "last-lab"
  env                      = "dev"
  region                   = "asia-northeast3"
  psa_cidr                 = "10.30.0.0/16"
  router_asn               = 64514
  subnet_cidr              = "10.20.0.0/26"
  routing_mode             = "REGIONAL"
  private_ip_google_access = true
}

run "preserve_existing_names" {
  command = plan
  assert {
    condition     = contains(keys(google_project_service.required), "artifactregistry.googleapis.com")
    error_message = "신규 환경의 이미지 저장소 생성을 위해 Artifact Registry API를 활성화해야 합니다."
  }
  assert {
    condition = (
      output.router_name == "last-lab-dev-dr-router" &&
      output.psa_range_name == "last-lab-dev-dr-psa"
    )
    error_message = "project/env에서 조립한 이름이 기존 DR 리소스 이름을 보존해야 합니다."
  }
}
