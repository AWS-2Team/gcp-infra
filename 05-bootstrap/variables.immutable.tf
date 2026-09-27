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

variable "state_bucket_name" {
  description = "New globally unique bucket name; never reuse an uninspected existing bucket."
  type        = string
}
variable "state_location" { type = string }
variable "state_admin_members" {
  description = "Explicit user:/group:/serviceAccount: principals authorized to read the whole State."
  type        = set(string)
}
