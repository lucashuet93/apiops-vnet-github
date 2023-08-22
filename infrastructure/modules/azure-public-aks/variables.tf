variable "aks_name" {
  type = string
}

variable "aks_rg" {
  type = string
}

variable "aks_location" {
  type    = string
  default = "West Europe"
}

variable "aks_version" {
  type    = string
  default = "1.26.6"
}

variable "aks_pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "aks_service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}

variable "default_vm_size" {
  type    = string
  default = "Standard_B2als_v2"
}

variable "default_pool_min_nodes" {
  type    = number
  default = 2
}

variable "default_pool_max_nodes" {
  type    = number
  default = 5
}

variable "default_pool_os_disk_size_gb" {
  type    = number
  default = 32
}
