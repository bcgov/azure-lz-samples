variable "existing_virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group containing the virtual network"
  type        = string
}

variable "existing_virtual_network_name" {
  description = "(Required) The name of the existing virtual network"
  type        = string
}

variable "github_hosted_runners_subnet_name" {
  description = "(Required) The name of the subnet to use for the GitHub hosted runners (which will be VNet injected)"
  type        = string
}

variable "github_hosted_runners_subnet_address_prefix" {
  description = "(Required) The address prefix for the GitHub hosted runners subnet"
  type        = string
}

variable "network_settings_name" {
  description = "(Required) The name of the network settings resource"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.network_settings_name))
    error_message = "The network settings name must start and end with an alphanumeric character and can contain hyphens in between."
  }
}
