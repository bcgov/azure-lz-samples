variable "name" {
  description = "(Required) Azure Virtual Desktop workspace name."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group name for the workspace."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the workspace."
  type        = string
}

variable "friendly_name" {
  description = "(Optional) Friendly display name for the workspace."
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional) Description for the workspace."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is enabled for the workspace. Defaults to false for policy-aligned private access."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Tags to apply to the workspace."
  type        = map(string)
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics Workspace resource ID for diagnostic settings."
  type        = string
  default     = null
}

variable "diagnostic_log_category_group" {
  description = "(Optional) Diagnostic log category group. For AVD workspaces, this must be 'allLogs'."
  type        = string
  default     = "allLogs"

  validation {
    condition     = var.diagnostic_log_category_group == "allLogs"
    error_message = "diagnostic_log_category_group must be 'allLogs' for AVD workspaces."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created for the workspace."
  type        = bool
  default     = false
}

variable "private_endpoints" {
  description = "(Optional) Private endpoints to create for the workspace."
  type = map(object({
    subnet_id         = string
    subresource_names = list(string)
  }))
  default = {}
}
