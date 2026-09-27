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

variable "network" {
  description = "10-network network output; only the listed contract fields are consumed."
  type        = object({ id = string, subnetwork_id = string, pods_range_name = string, services_range_name = string })
}
variable "location" {
  description = "Chosen cluster region or zone. Node pool limits are TOTAL across zones."
  type        = string
}
