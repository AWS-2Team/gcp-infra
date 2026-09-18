variable "project_id" { type = string }
variable "region" { type = string }
variable "name" { type = string }
variable "vpn_gateway_id" { type = string }
variable "router_id" { type = string }
variable "router_name" { type = string }

variable "tunnels" {
  type = map(object({
    external_ip    = string
    gcp_bgp_cidr   = string
    aws_bgp_ip     = string
    secret_version = string
  }))
  validation {
    condition     = toset(keys(var.tunnels)) == toset(["0", "1"])
    error_message = "키가 0, 1인 AWS 터널 2개가 필요합니다. AWS에서 실제 주소를 발급받기 전에는 적용하지 마세요."
  }
  validation {
    condition = alltrue([for t in values(var.tunnels) : try(
      can(cidrnetmask("${t.external_ip}/32")) &&
      startswith(t.gcp_bgp_cidr, "169.254.") && endswith(t.gcp_bgp_cidr, "/30") &&
      cidrhost(t.gcp_bgp_cidr, 0) == cidrhost("${t.aws_bgp_ip}/30", 0) &&
      contains([cidrhost(t.gcp_bgp_cidr, 1), cidrhost(t.gcp_bgp_cidr, 2)], split("/", t.gcp_bgp_cidr)[0]) &&
      contains([cidrhost(t.gcp_bgp_cidr, 1), cidrhost(t.gcp_bgp_cidr, 2)], t.aws_bgp_ip) &&
      split("/", t.gcp_bgp_cidr)[0] != t.aws_bgp_ip &&
    can(regex("^[1-9][0-9]*$", t.secret_version)), false)])
    error_message = "유효한 외부 IPv4 주소를 입력하세요. 터널마다 같은 169.254.x.x/30 대역의 서로 다른 호스트 IP와 양의 정수인 공유 키 버전을 지정하세요."
  }
  validation {
    condition     = length(distinct([for t in values(var.tunnels) : try(cidrhost(t.gcp_bgp_cidr, 0), "invalid")])) == length(var.tunnels)
    error_message = "각 터널은 서로 다른 /30 BGP 대역을 사용해야 합니다."
  }
}
