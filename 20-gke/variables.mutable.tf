variable "release_channel" {
  type    = string
  default = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Use a managed release channel."
  }
}
variable "maintenance_start_utc" { type = string }
variable "node_pools" {
  description = "Explicit baseline and autoscaler limits. Terraform does not reset live node counts."
  type        = map(object({ machine_type = string, disk_size_gb = number, initial_nodes = number, min_nodes = number, max_nodes = number, zones = set(string), spot = bool }))
  validation {
    condition     = length(var.node_pools) > 0 && alltrue([for p in values(var.node_pools) : p.min_nodes >= 0 && p.max_nodes >= max(1, p.min_nodes) && p.initial_nodes >= 1 && length(p.zones) > 0 && p.initial_nodes * length(p.zones) >= p.min_nodes && p.initial_nodes * length(p.zones) <= p.max_nodes && p.disk_size_gb >= 20])
    error_message = "Supply pools with valid total autoscaling bounds and a per-zone initial count inside those bounds."
  }
}
