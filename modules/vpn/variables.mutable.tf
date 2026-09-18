variable "peer_asn" {
  type = number
  validation {
    condition     = floor(var.peer_asn) == var.peer_asn && var.peer_asn >= 1 && var.peer_asn <= 4294967294
    error_message = "유효한 상대 피어 ASN을 입력하세요."
  }
}
variable "advertised_route_priority" {
  type = number
  validation {
    condition     = floor(var.advertised_route_priority) == var.advertised_route_priority && var.advertised_route_priority >= 1 && var.advertised_route_priority <= 65535
    error_message = "경로 우선순위는 1~65535 범위의 정수로 입력하세요."
  }
}
