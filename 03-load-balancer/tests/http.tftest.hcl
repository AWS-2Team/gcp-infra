mock_provider "google" {}

variables {
  project_id = "kdt4-2-506106"
  region     = "asia-northeast3"
  project    = "last-lab"
  env        = "dev"
  cloud_run_services = {
    app = "last-lab-dev-dr-app"
    web = "last-lab-dev-dr-web"
  }
  web_paths = ["/resources/*", "/nginx-health"]
}

run "http_routing" {
  command = apply

  assert {
    condition     = google_compute_global_forwarding_rule.http.port_range == "80" && google_compute_global_forwarding_rule.http.load_balancing_scheme == "EXTERNAL_MANAGED"
    error_message = "PoC 진입점은 글로벌 외부 HTTP 80이어야 합니다."
  }

  assert {
    condition     = google_compute_url_map.http.default_service == google_compute_backend_service.cloud_run["app"].id && google_compute_url_map.http.path_matcher[0].default_service == google_compute_backend_service.cloud_run["app"].id
    error_message = "기본 경로는 App으로 연결해야 합니다."
  }

  assert {
    condition     = toset(google_compute_url_map.http.path_matcher[0].path_rule[0].paths) == toset(["/resources/*", "/nginx-health"]) && google_compute_url_map.http.path_matcher[0].path_rule[0].service == google_compute_backend_service.cloud_run["web"].id
    error_message = "정적 파일과 Nginx 확인 경로는 Web으로 연결해야 합니다."
  }
}
