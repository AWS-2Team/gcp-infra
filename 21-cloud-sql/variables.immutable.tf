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

variable "recovery_unit" {
  description = "Business recovery identity; one instance and one backend prefix per recovery unit."
  type        = string
}
variable "network" {
  description = "10-network output; apply only after its service-networking connection completes."
  type        = object({ id = string, sql_range_name = string })
}
