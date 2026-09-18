output "network_id" {
  description = "Cloud SQL 및 Cloud Run CLI에서 참조할 VPC ID"
  value       = module.backbone.network_id
}
output "subnet_id" {
  value = module.backbone.subnet_id
}
output "psa_range_name" {
  value = module.backbone.psa_range_name
}
output "psa_cidr" {
  value = var.psa_cidr
}
output "vpn_gateway_id" {
  value = module.backbone.vpn_gateway_id
}
output "vpn_gateway_ips" {
  description = "AWS 고객 게이트웨이에서 사용할 GCP HA VPN의 인터페이스별 공인 IP"
  value       = module.backbone.vpn_gateway_ips
}
output "router_name" {
  value = module.backbone.router_name
}
output "router_asn" {
  value = var.router_asn
}
