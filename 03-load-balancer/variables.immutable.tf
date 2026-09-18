variable "project_id" {
  type        = string
  description = "LB를 소유할 GCP 프로젝트 ID"
}

variable "region" {
  type        = string
  description = "Cloud Run과 Serverless NEG의 GCP 리전"
}

variable "project" {
  type        = string
  description = "이름과 공통 라벨에 사용할 프로젝트 식별자"
}

variable "env" {
  type        = string
  description = "환경 이름"
}

variable "cloud_run_services" {
  type        = map(string)
  description = "CLI로 배포한 App과 Web의 Cloud Run 서비스 이름"
  validation {
    condition     = toset(keys(var.cloud_run_services)) == toset(["app", "web"])
    error_message = "서비스 목록에는 app과 web을 각각 지정해야 합니다."
  }
}
