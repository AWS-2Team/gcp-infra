output "tunnel_names" {
  description = "CLI로 연결 상태를 조회할 터널 이름"
  value       = module.vpn.tunnel_names
}
output "bgp_peer_names" { value = module.vpn.bgp_peer_names }
