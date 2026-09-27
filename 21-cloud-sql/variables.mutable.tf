variable "tier" { type = string }
variable "availability_type" {
  type = string
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Choose ZONAL or REGIONAL explicitly."
  }
}
variable "disk_size_gb" { type = number }
variable "disk_autoresize_limit_gb" { type = number }
variable "backup_start_utc" { type = string }
variable "retained_backups" {
  type = number
  validation {
    condition     = var.retained_backups >= 1
    error_message = "At least one retained backup is required."
  }
}
variable "transaction_log_retention_days" {
  type = number
  validation {
    condition     = var.transaction_log_retention_days >= 1 && var.transaction_log_retention_days <= 7
    error_message = "Enterprise MySQL log retention is 1..7 days."
  }
}
variable "maintenance_day" { type = number }
variable "maintenance_hour_utc" { type = number }
variable "notification_channels" {
  description = "Existing Monitoring channel resource names, selected by operator; no secrets."
  type        = list(string)
}
variable "disk_alert_fraction" {
  type = number
  validation {
    condition     = var.disk_alert_fraction > 0 && var.disk_alert_fraction < 1
    error_message = "Threshold must be a fraction between zero and one."
  }
}
