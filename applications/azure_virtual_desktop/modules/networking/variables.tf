variable "location" {
  description = "(Required) Azure region for created supporting resources."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group for created supporting resources."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags to apply to created supporting resources."
  type        = map(string)
  default     = null
}

variable "virtual_network_id" {
  description = "(Required) Resource ID of the existing virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "(Required) Name of the existing virtual network."
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "(Required) Resource group name of the existing virtual network."
  type        = string
}

variable "network_security_groups" {
  description = "(Optional) Network security groups to create."
  type = map(object({
    name = string
    security_rules = optional(map(object({
      name                         = optional(string)
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      description                  = optional(string)
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
  }))
  default = {}
}

variable "subnets" {
  description = "(Optional) Subnets to create in the existing virtual network. A subnet can optionally attach to a created network security group using network_security_group_key."
  type = map(object({
    name                                          = string
    address_prefixes                              = list(string)
    network_security_group_key                    = optional(string)
    service_endpoints                             = optional(list(string), [])
    delegation_name                               = optional(string)
    delegation_service_name                       = optional(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {}
}

variable "existing_subnet_ids" {
  description = "(Optional) Map of pre-existing subnet resource IDs (key => id) to include in outputs alongside created subnets. Use this when a required subnet was provisioned outside this module."
  type        = map(string)
  default     = {}
}

variable "existing_network_security_group_ids" {
  description = "(Optional) Map of pre-existing NSG resource IDs (key => id) to include in outputs alongside created NSGs."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics Workspace resource ID for NSG diagnostic settings."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created for NSGs in this module."
  type        = bool
  default     = false
}
