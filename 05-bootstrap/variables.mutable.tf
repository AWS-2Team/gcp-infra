variable "log_retention_days" {
  type        = number
  description = "Retention for the project's default log bucket; project-wide effect."
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 3650
    error_message = "Log retention must be 1..3650 days."
  }
}
