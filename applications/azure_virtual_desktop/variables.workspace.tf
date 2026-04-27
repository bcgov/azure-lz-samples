variable "workspaces" {
  description = "(Optional) Azure Virtual Desktop workspaces to create. Application groups are associated using application_groups[*].workspace_key."
  type = map(object({
    name                          = string
    friendly_name                 = optional(string)
    description                   = optional(string)
    diagnostic_log_category_group = optional(string, "allLogs")
  }))
  default = {}
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
  }))
  default = {}
}
