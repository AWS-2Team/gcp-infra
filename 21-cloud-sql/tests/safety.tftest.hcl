mock_provider "google" {}
variables {
  project_id                     = "example-dr-project"
  region                         = "asia-northeast3"
  project                        = "last-lab"
  env                            = "dev"
  recovery_unit                  = "orders"
  network                        = { id = "projects/example-dr-project/global/networks/test", sql_range_name = "sql-range" }
  tier                           = "db-custom-1-3840"
  availability_type              = "ZONAL"
  disk_size_gb                   = 20
  disk_autoresize_limit_gb       = 100
  backup_start_utc               = "18:00"
  retained_backups               = 7
  transaction_log_retention_days = 7
  maintenance_day                = 7
  maintenance_hour_utc           = 19
  notification_channels          = []
  disk_alert_fraction            = 0.8
}
run "private_protected_recovery_unit" {
  command = plan
  assert {
    condition     = google_sql_database_instance.this.name == "last-lab-dev-dr-orders-sql" && google_sql_database_instance.this.deletion_protection && google_sql_database_instance.this.settings[0].deletion_protection_enabled
    error_message = "Database identity and both deletion protection layers must be retained."
  }
  assert {
    condition     = !google_sql_database_instance.this.settings[0].ip_configuration[0].ipv4_enabled && google_sql_database_instance.this.settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY" && google_sql_database_instance.this.settings[0].backup_configuration[0].binary_log_enabled
    error_message = "SQL requires private IP, TLS and PITR binlogs."
  }
}
run "reject_disk_limit_below_size" {
  command = plan
  variables { disk_autoresize_limit_gb = 10 }
  expect_failures = [google_sql_database_instance.this]
}
