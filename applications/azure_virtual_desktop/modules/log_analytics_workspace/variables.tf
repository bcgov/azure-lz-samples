variable "name" {
  description = "(Required) Log Analytics Workspace name."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group name."
  type        = string
}

variable "location" {
  description = "(Required) Azure region."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags to apply to the workspace."
  type        = map(string)
  default     = null
}

variable "sku" {
  description = "(Optional) SKU. Defaults to PerGB2018."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "sku must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "retention_in_days" {
  description = "(Optional) Data retention in days. Must be between 7 and 730. Defaults to 30."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 7 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 7 and 730."
  }
}

variable "daily_quota_gb" {
  description = "(Optional) Daily ingestion quota in GB. Use -1 to disable the quota. Defaults to -1."
  type        = number
  default     = -1
}

variable "diagnostic_log_category_group" {
  description = "(Optional) Diagnostic log category group for self-diagnostics. Must be 'audit' or 'allLogs'. Defaults to 'audit'."
  type        = string
  default     = "audit"

  validation {
    condition     = contains(["audit", "allLogs"], var.diagnostic_log_category_group)
    error_message = "diagnostic_log_category_group must be 'audit' or 'allLogs'."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created for the workspace."
  type        = bool
  default     = true
}
