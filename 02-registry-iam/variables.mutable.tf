variable "cloud_run_display_name" {
  type        = string
  description = "Cloud Run 실행 계정 표시 이름"
}

variable "cloud_run_web_display_name" {
  type        = string
  description = "DB 권한 없이 사용할 Cloud Run Web 실행 계정 표시 이름"
}

variable "artifact_registry_description" {
  type        = string
  description = "App 이미지 저장소 설명"
}

variable "artifact_registry_web_description" {
  type        = string
  description = "Web 이미지 저장소 설명"
}
