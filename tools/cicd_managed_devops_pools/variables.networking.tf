variable "virtual_network_resource_group" {
  description = "The name of the resource group containing the virtual network"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the existing virtual network"
  type        = string
}

variable "managed_devops_pool_subnet_name" {
  description = "The name of the existing subnet to use for the Managed DevOps Pool"
  type        = string
}
