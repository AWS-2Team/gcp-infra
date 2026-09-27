variable "project_id" {
  description = "Existing billing-enabled Google project ID, selected with gcloud projects list."
  type        = string
}
variable "project" {
  description = "Naming identity, not Google project ID. Changing it can replace resources."
  type        = string
  default     = "last-lab"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Use a lowercase naming prefix."
  }
}
variable "env" {
  description = "Environment identity; changing it can replace resources."
  type        = string
  default     = "dev"
}
variable "region" {
  description = "Chosen deployment region; changing it requires a relocation plan."
  type        = string
}

variable "vpn_foundation" {
  description = "10-network output vpn_foundation."
  type        = object({ gateway_id = string, router_name = string, asn = number })
}
variable "aws_peer" {
  description = "AWS 11-vpn aws_peer output; copy only nonsensitive metadata."
  type = object({
    aws_asn = number
    tunnels = map(object({ external_ip = string, aws_bgp_ip = string, gcp_bgp_cidr = string, psk_secret_arn = string }))
  })
  validation {
    condition     = toset(keys(var.aws_peer.tunnels)) == toset(["tunnel1", "tunnel2"]) && var.aws_peer.aws_asn != var.vpn_foundation.asn
    error_message = "Provide exactly tunnel1/tunnel2 and distinct AWS/GCP ASNs."
  }
}
