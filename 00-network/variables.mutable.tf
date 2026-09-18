variable "subnet_cidr" {
  type        = string
  description = "서브넷 IPv4 CIDR. 기존 범위를 포함하는 확장만 무교체 변경 가능하며 축소는 교체 대상입니다."
}

variable "routing_mode" {
  type        = string
  description = "REGIONAL/GLOBAL은 VPC 재생성 없이 변경 가능하지만 경로 전파 범위가 달라집니다."
}

variable "private_ip_google_access" {
  type        = bool
  description = "서브넷의 Private Google Access 활성 여부. 서브넷 재생성 없이 변경 가능합니다."
}
