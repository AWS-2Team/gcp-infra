variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "유효한 GCP 프로젝트 ID를 입력하세요."
  }
}
variable "region" {
  type = string
}
variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,48}[a-z0-9])?$", var.name))
    error_message = "GCP 리소스 이름 접두사는 영문 소문자로 시작하는 50자 이하의 값으로 입력하세요."
  }
}
variable "psa_cidr" {
  type = string
  validation {
    condition     = can(cidrnetmask(var.psa_cidr)) && can(regex("/(1[6-9]|2[0-4])$", var.psa_cidr))
    error_message = "PSA 대역은 접두사 길이가 /16~/24인 IPv4 CIDR이어야 합니다."
  }
}
variable "router_asn" {
  type = number
  validation {
    condition     = floor(var.router_asn) == var.router_asn && ((var.router_asn >= 64512 && var.router_asn <= 65534) || (var.router_asn >= 4200000000 && var.router_asn <= 4294967294))
    error_message = "Cloud Router에는 RFC6996의 사설 ASN이 필요합니다."
  }
}
