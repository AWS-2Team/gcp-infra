variable "subnet_cidr" {
  type        = string
  description = "무교체 변경은 기존 대역을 포함하는 확장만 허용됩니다."
  validation {
    condition     = can(cidrnetmask(var.subnet_cidr)) && can(regex("/(1[6-9]|2[0-6])$", var.subnet_cidr))
    error_message = "Cloud Run의 직접 VPC 송신에 사용할 서브넷은 /16~/26 크기의 IPv4 대역으로 지정하세요."
  }
}
variable "routing_mode" {
  type = string
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "라우팅 범위는 REGIONAL 또는 GLOBAL로 지정하세요."
  }
}
variable "private_ip_google_access" {
  type = bool
}
