variable "services" {
  description = "Map short service keys to explicit account IDs and Kubernetes identities. IDs are 6..30 chars."
  type        = map(object({ account_id = string, namespace = string, kubernetes_service_account = string, cloud_sql_access = bool, secret_names = set(string) }))
  validation {
    condition     = alltrue([for s in values(var.services) : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", s.account_id)) && alltrue([for n in s.secret_names : contains(var.secret_names, n)])])
    error_message = "Service account IDs must be 6..30 lowercase characters and secret names must be declared."
  }
}
variable "image_writer_members" {
  description = "Repository key to identities allowed to push images; keep node identities read-only."
  type        = map(set(string))
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.image_writer_members) : contains(var.repositories, k)])
    error_message = "Every writer binding must name a retained repository."
  }
}
