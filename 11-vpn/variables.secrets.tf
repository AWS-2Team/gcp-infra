variable "shared_secrets" {
  description = "Supply securely through TF_VAR_shared_secrets only for this command; never save in tfvars."
  type        = map(string)
  sensitive   = true
  ephemeral   = true
  validation {
    condition     = toset(keys(var.shared_secrets)) == toset(["tunnel1", "tunnel2"]) && alltrue([for s in values(var.shared_secrets) : length(s) >= 8])
    error_message = "Both tunnel keys must be supplied."
  }
}
