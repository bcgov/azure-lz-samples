variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "virtual_network_resource_group" {
  description = "Name of the resource group containing the virtual network"
  type        = string
}

variable "containerSubnetName" {
  description = "Name of the subnet to use for Cloud Shell containers."
  type        = string
  default     = "cloudshellsubnet"
}

variable "relaySubnetName" {
  description = "Name of the subnet to use for Azure Relay."
  type        = string
  default     = "relaysubnet"
}

variable "storageSubnetName" {
  description = "Name of the subnet to use for storage."
  type        = string
  default     = "storagesubnet"
}

variable "containerSubnetAddressPrefix" {
  description = "Address prefix for the container subnet."
  type        = string
}

variable "relaySubnetAddressPrefix" {
  description = "Address prefix for the relay subnet."
  type        = string
}

variable "storageSubnetAddressPrefix" {
  description = "Address prefix for the storage subnet."
  type        = string
}

variable "privateEndpointName" {
  description = "Name of Private Endpoint for Azure Relay."
  type        = string
  default     = "cloudshellRelayEndpoint"
}
