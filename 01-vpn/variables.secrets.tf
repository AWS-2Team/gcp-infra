variable "shared_secrets" {
  type        = map(string)
  description = "AWS 터널 PSK. TF_VAR_shared_secrets 등으로 주입하며 일반 tfvars/Git에 저장하지 않습니다."
  sensitive   = true
  ephemeral   = true
  default     = {}
}
