variable "project_id" {
  type        = string
  description = "터널 소유 프로젝트. 변경 시 재생성됩니다."
}
variable "region" {
  type        = string
  description = "터널 생성 리전. 변경 시 재생성됩니다."
}
variable "project" {
  type        = string
  description = "이름과 공통 라벨에 사용할 프로젝트 식별자. GCP project_id와 구분합니다."
}

variable "env" {
  type        = string
  description = "환경 이름 (dev, stg, prod). project와 함께 기존 리소스 이름을 결정합니다."
}
variable "tunnels" {
  description = "AWS VPN 연결 하나가 생성한 터널 2개의 연결 주소. 두 터널 모두 GCP 인터페이스 0을 사용합니다. 주소/매핑 변경은 연결 재구성이므로 고정 관리합니다. secret_version 변경은 터널 교체를 유발합니다."
  type = map(object({
    external_ip    = string
    gcp_bgp_cidr   = string
    aws_bgp_ip     = string
    secret_version = string
  }))
}
