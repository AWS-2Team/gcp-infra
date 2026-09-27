resource "google_compute_global_address" "gateway" {
  name         = "${local.name}-gateway-ip"
  address_type = "EXTERNAL"
  lifecycle { prevent_destroy = true }
}
resource "google_certificate_manager_dns_authorization" "this" {
  for_each = var.domains
  name     = "${local.name}-${replace(each.key, ".", "-")}-auth"
  domain   = each.key
  type     = "PER_PROJECT_RECORD"
}
resource "google_dns_record_set" "authorization" {
  for_each     = var.dns_zone == null ? toset([]) : var.domains
  project      = var.dns_zone.project_id
  managed_zone = var.dns_zone.name
  name         = google_certificate_manager_dns_authorization.this[each.key].dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.this[each.key].dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.this[each.key].dns_resource_record[0].data]
}
resource "google_certificate_manager_certificate" "this" {
  name = "${local.name}-gateway-cert"
  managed {
    domains            = sort(tolist(var.domains))
    dns_authorizations = [for d in sort(tolist(var.domains)) : google_certificate_manager_dns_authorization.this[d].id]
  }
  lifecycle { prevent_destroy = true }
}
resource "google_certificate_manager_certificate_map" "this" {
  name = "${local.name}-gateway-map"
  lifecycle { prevent_destroy = true }
}
resource "google_certificate_manager_certificate_map_entry" "this" {
  for_each     = var.domains
  name         = "${local.name}-${replace(each.key, ".", "-")}-entry"
  map          = google_certificate_manager_certificate_map.this.name
  certificates = [google_certificate_manager_certificate.this.id]
  hostname     = each.key
}
output "gateway" {
  value = { address_name = google_compute_global_address.gateway.name, address = google_compute_global_address.gateway.address, certificate_map = google_certificate_manager_certificate_map.this.name, domains = var.domains }
}
output "dns_authorizations" { value = { for k, a in google_certificate_manager_dns_authorization.this : k => a.dns_resource_record[0] } }
