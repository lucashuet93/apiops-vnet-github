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

variable "services_rg_name" {
  type    = string
  default = "apim-services"
}

variable "backend_rg_name" {
  type    = string
  default = "apim-backend"
}

variable "dns_domain" {
  type    = string
  default = ""
}

variable "acr_name" {
  type = string
}

variable "akv_name" {
  type = string
}

variable "aks_name" {
  type    = string
  default = "apim-backend-aks"
}

variable "dev_backend_environments" {
  type    = list(string)
  default = ["apim-be-dev", "apim-be-test"]
}

variable "prod_backend_environments" {
  type    = list(string)
  default = ["apim-be-stage", "apim-be-prod"]
}
