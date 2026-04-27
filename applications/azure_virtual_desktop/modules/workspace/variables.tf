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
  description = "(Optional) Diagnostic log category group. Must be 'audit' or 'allLogs'. Defaults to 'allLogs'."
  type        = string
  default     = "allLogs"

  validation {
    condition     = contains(["audit", "allLogs"], var.diagnostic_log_category_group)
    error_message = "diagnostic_log_category_group must be 'audit' or 'allLogs'."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created for the workspace."
  type        = bool
  default     = false
}
