variable "resource_group_id" {
  description = "(Required) Resource group ID where scaling plans are created."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the scaling plans."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags to apply to scaling plan resources."
  type        = map(string)
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics Workspace resource ID for diagnostic settings. When set, AllLogs are forwarded to the workspace."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created. Must be true only when log_analytics_workspace_id is also set. Separate bool keeps for_each keys known at plan time."
  type        = bool
  default     = false
}

variable "scaling_plans" {
  description = "(Optional) Map of scaling plans to create. Each plan can reference one or more host pools."
  type = map(object({
    name                          = string
    friendly_name                 = optional(string)
    description                   = optional(string)
    exclusion_tag                 = optional(string)
    host_pool_type                = optional(string) # Pooled or Personal; defaults to Pooled
    time_zone                     = optional(string) # IANA or Windows time zone; defaults to "UTC"
    diagnostic_log_category_group = optional(string, "allLogs")
    host_pool_references = optional(list(object({
      host_pool_id = string
      enabled      = optional(bool)
    })), [])
    schedules = optional(list(any), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for plan in values(var.scaling_plans) :
      contains(["Pooled", "Personal"], coalesce(try(plan.host_pool_type, null), "Pooled"))
    ])
    error_message = "Each scaling_plan host_pool_type must be Pooled or Personal."
  }

  validation {
    condition = alltrue([
      for plan in values(var.scaling_plans) :
      coalesce(try(plan.diagnostic_log_category_group, null), "allLogs") == "allLogs"
    ])
    error_message = "Each scaling plan diagnostic_log_category_group must be allLogs."
  }
}
