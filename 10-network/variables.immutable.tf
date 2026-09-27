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

variable "cidrs" {
  description = "New nonoverlapping IPv4 ranges; compare against all connected AWS/GCP networks."
  type        = object({ nodes = string, pods = string, services = string, sql = string })
  validation {
    condition     = alltrue([for c in values(var.cidrs) : can(cidrnetmask(c))])
    error_message = "All four ranges must be valid IPv4 CIDRs."
  }
}
variable "aws_cidrs" {
  description = "Actual connected AWS network ranges, used for overlap validation, not firewall blanket access."
  type        = set(string)
  validation {
    condition     = length(var.aws_cidrs) > 0 && alltrue([for c in var.aws_cidrs : can(cidrnetmask(c))])
    error_message = "Supply the connected AWS IPv4 ranges."
  }
}
variable "router_asn" {
  type = number
  validation {
    condition     = var.router_asn >= 64512 && var.router_asn <= 65534 && floor(var.router_asn) == var.router_asn
    error_message = "Use a private integer ASN 64512..65534, matching the AWS peer input contract."
  }
}
