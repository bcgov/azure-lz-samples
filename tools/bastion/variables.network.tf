variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "virtual_network_resource_group" {
  description = "Name of the resource group containing the virtual network"
  type        = string
}

variable "bastionSubnetAddressPrefix" {
  description = "Address prefix for the bastion subnet. Must be at least w.x.y.z/26"
  type        = string

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/(\\d{1,2})$", var.bastionSubnetAddressPrefix)) && tonumber(split("/", var.bastionSubnetAddressPrefix)[1]) <= 26
    error_message = "bastionSubnetAddressPrefix must be in the form w.x.y.z/26 or larger (e.g., /25, /24, etc.)"
  }
}
