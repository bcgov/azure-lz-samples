variable "name" {
  description = "(Required) Azure Virtual Desktop application group name."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group name for the application group."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the application group."
  type        = string
}

variable "host_pool_id" {
  description = "(Required) Host pool resource ID associated with the application group."
  type        = string
}

variable "type" {
  description = "(Required) Application group type. Must be Desktop or RailApplications."
  type        = string

  validation {
    condition     = contains(["Desktop", "RailApplications"], var.type)
    error_message = "type must be Desktop or RailApplications."
  }
}

variable "friendly_name" {
  description = "(Optional) Friendly display name for the application group."
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional) Description for the application group."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) Tags to apply to the application group."
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
  description = "(Optional) When true, diagnostic settings are created for the application group."
  type        = bool
  default     = false
}
