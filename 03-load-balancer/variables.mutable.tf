variable "web_paths" {
  type        = list(string)
  description = "Web 백엔드로 전달할 경로. 나머지는 App으로 전달합니다."
}
