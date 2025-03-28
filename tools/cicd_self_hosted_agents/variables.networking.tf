variable "existing_virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group containing the virtual network"
  type        = string
}

variable "existing_virtual_network_name" {
  description = "(Required) The name of the existing virtual network"
  type        = string
}

variable "container_app_subnet_name" {
  description = "(Required) The name of the existing subnet to use for the container app"
  type        = string
}

variable "container_app_subnet_address_prefix" {
  description = "(Required) The address prefix for the container app subnet"
  type        = string
}

variable "container_instance_subnet_name" {
  description = "(Required) The name of the existing subnet to use for the container instance"
  type        = string
}

variable "container_instance_subnet_address_prefix" {
  description = "(Required) The address prefix for the container instance subnet"
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "(Required) The name of the existing subnet for Private Endpoints"
  type        = string
}

variable "private_endpoint_subnet_address_prefix" {
  description = "(Required) The address prefix for the private endpoint subnet"
  type        = string
}
