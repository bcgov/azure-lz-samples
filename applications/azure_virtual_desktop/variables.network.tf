variable "virtual_network_name" {
  description = "(Required) The name of the existing virtual network used for Azure Virtual Desktop supporting resources."
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group containing the existing virtual network."
  type        = string
}

variable "network_security_groups" {
  description = "(Optional) Network security groups to create in the AVD resource group for later subnet attachment."
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

  validation {
    condition = alltrue(flatten([
      for nsg in values(var.network_security_groups) : [
        for rule in values(nsg.security_rules) :
        contains(["Inbound", "Outbound"], rule.direction) &&
        contains(["Allow", "Deny"], rule.access)
      ]
    ]))
    error_message = "Each network security rule must use direction Inbound or Outbound and access Allow or Deny."
  }
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
    private_endpoint_network_policies_enabled     = optional(bool, false)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for subnet in values(var.subnets) : [
        for prefix in subnet.address_prefixes : can(cidrhost(prefix, 0))
      ]
    ]))
    error_message = "Each subnet address_prefixes entry must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      alltrue([
        for prefix in subnet.address_prefixes :
        tonumber(split("/", prefix)[1]) <= 27
      ])
    ])
    error_message = "Each subnet must be at least /27 (prefix length <= 27) for production readiness."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      try(subnet.network_security_group_key, null) == null || contains(keys(var.network_security_groups), subnet.network_security_group_key)
    ])
    error_message = "Each subnet network_security_group_key must reference a key in network_security_groups when set."
  }
}

variable "existing_subnet_ids" {
  description = "(Optional) Map of pre-existing subnet resource IDs (key => id). Use this when a subnet required by this deployment already exists and should not be recreated. The key is referenced by Key Vault private_endpoint_subnet_key."
  type        = map(string)
  default     = {}
}

variable "existing_network_security_group_ids" {
  description = "(Optional) Map of pre-existing NSG resource IDs (key => id) to surface in networking outputs."
  type        = map(string)
  default     = {}
}
