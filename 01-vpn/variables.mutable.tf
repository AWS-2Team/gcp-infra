variable "peer_asn" {
  type        = number
  description = "GCP BGP 피어의 상대 ASN. 피어 재생성 없이 수정 가능하나 실제 AWS ASN과 일치해야 하며 세션이 재연결됩니다."
}
variable "advertised_route_priority" {
  type        = number
  description = "BGP 광고 경로 우선순위. 터널 재생성 없이 변경되며 라우팅에 영향을 줍니다."
}
