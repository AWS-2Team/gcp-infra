variable "secret_versions" {
  description = "Increment the matching tunnel's integer whenever its key changes; coordinate rotation separately."
  type        = map(number)
  validation {
    condition     = toset(keys(var.secret_versions)) == toset(["tunnel1", "tunnel2"]) && alltrue([for v in values(var.secret_versions) : v >= 1 && floor(v) == v])
    error_message = "Provide positive integer versions for both tunnels."
  }
}
variable "route_priority" {
  type    = number
  default = 100
}
