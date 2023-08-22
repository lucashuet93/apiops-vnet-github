variable "public_ip_address" {
  type        = string
  description = "Public IP address"
  default     = ""
}

variable "chart_version" {
  type        = string
  description = "ingress-inginx helm chart version"
  default     = "4.7.1"
}

variable "chart_values_overrides" {
  type        = map(string)
  description = "variable = value to override in helm release"
  default     = {}
}

variable "dhparam_pem" {
  type        = string
  description = "DH Parameters (pem)"
  default     = ""
}

variable "chart_extra_values" {
  type        = string
  description = "ingress-nginx helm release extra values (yaml)"
  default     = ""
}
