output "network_id" { value = google_compute_network.this.id }
output "subnet_id" { value = google_compute_subnetwork.this.id }
output "psa_range_name" { value = google_compute_global_address.psa.name }
output "vpn_gateway_id" { value = google_compute_ha_vpn_gateway.this.id }
output "vpn_gateway_ips" {
  value = { for interface in google_compute_ha_vpn_gateway.this.vpn_interfaces : tostring(interface.id) => interface.ip_address }
}
output "router_name" { value = google_compute_router.this.name }
