variable "location" {
  type        = string
  description = "Specifies the supported Azure location (region) where the resources will be deployed"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "environment" {
  type        = string
  description = "Normally dev or prod"
}

variable "service_principal_object_id" {
  type        = string
  description = "The Service Principal Object ID"
}
