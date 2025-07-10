variable "existing_virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group containing the virtual network"
  type        = string
}

variable "existing_virtual_network_name" {
  description = "(Required) The name of the existing virtual network"
  type        = string
}

variable "github_hosted_runners_subnet_name" {
  description = "(Required) The name of the existing subnet to use for the GitHub hosted runners"
  type        = string
}

variable "github_hosted_runners_subnet_address_prefix" {
  description = "(Required) The address prefix for the GitHub hosted runners subnet"
  type        = string
}

variable "network_settings_name" {
  description = "(Required) The name of the network settings resource"
  type        = string
}
