locals {
  name_prefix = "${var.project}-${var.env}-dr"
}

resource "google_compute_global_address" "http" {
  name         = "${local.name_prefix}-http-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_region_network_endpoint_group" "cloud_run" {
  for_each              = var.cloud_run_services
  name                  = "${local.name_prefix}-${each.key}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = each.value
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_backend_service" "cloud_run" {
  for_each              = var.cloud_run_services
  name                  = "${local.name_prefix}-${each.key}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # Serverless NEG에는 별도 헬스 체크를 연결하지 않습니다.
  backend {
    group = google_compute_region_network_endpoint_group.cloud_run[each.key].id
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_url_map" "http" {
  name            = "${local.name_prefix}-http"
  default_service = google_compute_backend_service.cloud_run["app"].id

  host_rule {
    hosts        = ["*"]
    path_matcher = "petclinic"
  }

  path_matcher {
    name            = "petclinic"
    default_service = google_compute_backend_service.cloud_run["app"].id

    path_rule {
      paths   = var.web_paths
      service = google_compute_backend_service.cloud_run["web"].id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_target_http_proxy" "http" {
  name    = "${local.name_prefix}-http-proxy"
  url_map = google_compute_url_map.http.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${local.name_prefix}-http"
  ip_address            = google_compute_global_address.http.address
  target                = google_compute_target_http_proxy.http.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"

  lifecycle {
    prevent_destroy = true
  }
}
