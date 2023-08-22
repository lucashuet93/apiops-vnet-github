variable "acme_email" {
  type        = string
  description = "ACME registration email"
}

variable "chart_version" {
  type = string
  default = "v1.12.3"
}

variable "letsencrypt_tls_key" {
  type        = string
  default     = ""
  description = "Letsencrypt tls key"
}
