variable "project_id" {
  type        = string
  description = "리소스를 생성할 GCP 프로젝트 ID"
}

variable "region" {
  type        = string
  description = "서비스 기반 리소스의 GCP 리전"
}

variable "project" {
  type        = string
  description = "이름과 공통 라벨에 사용할 프로젝트 식별자"
}

variable "env" {
  type        = string
  description = "환경 이름"
}

variable "cloud_run_account_id" {
  type        = string
  description = "Cloud Run App 실행 계정 ID. 변경하면 재생성 대상입니다."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.cloud_run_account_id))
    error_message = "서비스 계정 ID는 영문 소문자, 숫자, 하이픈으로 구성한 6~30자여야 합니다."
  }
}

variable "artifact_registry_suffix" {
  type        = string
  description = "App 이미지 저장소 이름의 접미사. 변경하면 재생성 대상입니다."
}

variable "artifact_registry_web_suffix" {
  type        = string
  description = "Web 이미지 저장소 이름의 접미사. 변경하면 재생성 대상입니다."
}

variable "artifact_registry_format" {
  type        = string
  description = "저장소에 보관할 아티팩트 형식. 생성 후 변경할 수 없습니다."
}
