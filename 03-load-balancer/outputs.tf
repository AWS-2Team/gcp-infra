output "load_balancer_ip" {
  description = "HTTP LB의 고정 공인 IP"
  value       = google_compute_global_address.http.address
}

output "load_balancer_url" {
  description = "PoC 접속과 읽기 조회 검증에 사용할 HTTP 주소"
  value       = "http://${google_compute_global_address.http.address}"
}
