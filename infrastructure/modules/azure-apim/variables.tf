variable "location" {
  type        = string
  description = "Specifies the supported Azure location (region) where the resources will be deployed"
  default     = "West Europe"
}

variable "name" {
  type = string
}

#variable "prefix" {
#  type        = string
#  description = "Prefix for resource names"
#}
#
#variable "environment" {
#  type        = string
#  description = "Normally dev or prod"
#}

variable "contributors_sp_object_ids" {
  type        = list(string)
  description = "The Service Principal Object ID's"
  default     = []
}
