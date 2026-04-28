variable "workspaces" {
  description = "(Optional) Azure Virtual Desktop workspaces to create. Application groups are associated using application_groups[*].workspace_key."
  type = map(object({
    name                          = string
    friendly_name                 = optional(string)
    description                   = optional(string)
    public_network_access_enabled = optional(bool, false)
    diagnostic_log_category_group = optional(string, "allLogs")
    private_endpoints = optional(list(object({
      subnet_key        = string
      subresource_names = optional(list(string), ["feed"])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for workspace in values(var.workspaces) : [
        for private_endpoint in coalesce(try(workspace.private_endpoints, null), []) :
        contains(keys(var.subnets), private_endpoint.subnet_key) || contains(keys(var.existing_subnet_ids), private_endpoint.subnet_key)
      ]
    ]))
    error_message = "Each workspace private_endpoints.subnet_key must reference a subnet key from subnets or existing_subnet_ids."
  }
}

variable "application_groups" {
  description = "(Optional) Azure Virtual Desktop application groups to create and optionally associate with workspaces."
  type = map(object({
    name                          = string
    type                          = string
    host_pool_key                 = string
    friendly_name                 = optional(string)
    description                   = optional(string)
    workspace_key                 = optional(string)
    diagnostic_log_category_group = optional(string, "allLogs")
    assignments = optional(map(object({
      principal_id         = string
      principal_type       = optional(string)
      role_definition_name = optional(string, "Desktop Virtualization User")
    })), {})
  }))
  default = {}
}
