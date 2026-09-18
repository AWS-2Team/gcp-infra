output "tunnel_names" {
  value = { for k, v in google_compute_vpn_tunnel.this : k => v.name }
}
output "bgp_peer_names" {
  value = { for k, v in google_compute_router_peer.this : k => v.name }
}
