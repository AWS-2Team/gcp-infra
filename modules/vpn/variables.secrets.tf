variable "shared_secrets" {
  type      = map(string)
  sensitive = true
  ephemeral = true
  validation {
    condition     = toset(keys(var.shared_secrets)) == toset(["0", "1"]) && alltrue([for secret in values(var.shared_secrets) : length(secret) >= 8])
    error_message = "터널 2개에 각각 8자 이상의 PSK를 입력하세요."
  }
}
