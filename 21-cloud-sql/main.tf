resource "google_sql_database_instance" "this" {
  name                = "${local.name}-${var.recovery_unit}-sql"
  region              = var.region
  database_version    = "MYSQL_8_4"
  deletion_protection = true
  settings {
    tier                        = var.tier
    edition                     = "ENTERPRISE"
    availability_type           = var.availability_type
    disk_type                   = "PD_SSD"
    disk_size                   = var.disk_size_gb
    disk_autoresize             = true
    disk_autoresize_limit       = var.disk_autoresize_limit_gb
    deletion_protection_enabled = true
    ip_configuration {
      ipv4_enabled       = false
      private_network    = var.network.id
      allocated_ip_range = var.network.sql_range_name
      ssl_mode           = "ENCRYPTED_ONLY"
    }
    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true
      start_time                     = var.backup_start_utc
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }
    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour_utc
      update_track = "stable"
    }
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
    user_labels = { project = var.project, environment = var.env, recovery_unit = var.recovery_unit, managed_by = "terraform" }
  }
  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = var.disk_size_gb >= 10 && (var.disk_autoresize_limit_gb == 0 || var.disk_autoresize_limit_gb >= var.disk_size_gb)
      error_message = "Disk must be >=10GB; resize limit must be unlimited (0) or at least initial size."
    }
    ignore_changes = [settings[0].disk_size]
  }
}
resource "google_monitoring_alert_policy" "disk" {
  display_name          = "${local.name}-${var.recovery_unit}-sql-disk"
  combiner              = "OR"
  notification_channels = var.notification_channels
  conditions {
    display_name = "Cloud SQL disk utilization"
    condition_threshold {
      filter          = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/disk/utilization\" AND resource.label.database_id = \"${var.project_id}:${google_sql_database_instance.this.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.disk_alert_fraction
      duration        = "300s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  alert_strategy { auto_close = "1800s" }
}
output "database" {
  value = { name = google_sql_database_instance.this.name, connection_name = google_sql_database_instance.this.connection_name, private_ip = google_sql_database_instance.this.private_ip_address, recovery_unit = var.recovery_unit }
}
