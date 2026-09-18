variable "project_id" {
  type        = string
  description = "리소스 소유 프로젝트. 변경하면 다른 프로젝트에 재생성됩니다."
}

variable "region" {
  type        = string
  description = "서브넷, Cloud Router, HA VPN의 생성 리전. 이동 시 재생성됩니다."
}

variable "project" {
  type        = string
  description = "이름과 공통 라벨에 사용할 프로젝트 식별자. GCP project_id와 구분합니다."
}

variable "env" {
  type        = string
  description = "환경 이름 (dev, stg, prod). project와 함께 기존 리소스 이름을 결정합니다."
}

variable "psa_cidr" {
  type        = string
  description = "PSA 예약 주소와 접두사 길이. 변경 시 예약 대역 재생성이 필요합니다."
}

variable "router_asn" {
  type        = number
  description = "Cloud Router 생성 시 고정되는 GCP ASN. 프로바이더가 교체를 표시하지 않아도 운영 중 변경하지 않습니다."
}
