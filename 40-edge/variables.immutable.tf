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

variable "domains" {
  description = "Public DNS names whose authorization CNAMEs are exclusively managed here or delegated externally."
  type        = set(string)
  validation {
    condition     = length(var.domains) > 0
    error_message = "At least one public domain is required."
  }
}
variable "dns_zone" {
  description = "Existing Cloud DNS public zone name+project; null means publish output CNAMEs through external DNS operator. Traffic A records are never owned here."
  type        = object({ name = string, project_id = string })
  default     = null
}
