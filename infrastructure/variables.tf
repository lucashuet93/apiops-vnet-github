variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location (region) where the resources will be deployed"
  default     = "West Europe"
}

#variable "prefix" {
#  type        = string
#  description = "Prefix for resource names"
#}

variable "services_rg_name" {
  type    = string
  default = "apim-services"
}

variable "backend_rg_name" {
  type    = string
  default = "apim-backend"
}

variable "dns_domain" {
  type = string
}

variable "acr_name" {
  type    = string
  default = "gcacrapim"
}

variable "akv_name" {
  type    = string
  default = "gc-apim-akv"
}

variable "aks_name" {
  type    = string
  default = "apim-backend-aks"
}

variable "backend_endpoints" {
  type    = list(string)
  default = ["apim-be-dev", "apim-be-stage", "apim-be-prod", ]
}