variable "name" {
  description = "(Required) Storage account name. Must be globally unique, 3-24 lowercase alphanumeric characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "(Required) Resource group for the storage account."
  type        = string
}

variable "location" {
  description = "(Required) Azure region."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags to apply to all resources in this module."
  type        = map(string)
  default     = null
}

variable "account_tier" {
  description = "(Optional) Storage account tier. Premium is recommended for FSLogix (lower latency). Default: Premium."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "(Optional) Replication type for the storage account. LRS or ZRS are typical for FSLogix. Default: ZRS."
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "share_name" {
  description = "(Optional) Name of the Azure Files share for FSLogix profile containers. Default: profiles."
  type        = string
  default     = "profiles"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.share_name))
    error_message = "share_name must be 3-63 lowercase alphanumeric characters or hyphens, starting and ending with alphanumeric."
  }
}

variable "share_quota_gb" {
  description = "(Optional) Capacity ceiling for the Azure Files share, in GiB. Default: 1024 GiB."
  type        = number
  default     = 1024

  validation {
    condition     = var.share_quota_gb >= 100 && var.share_quota_gb <= 102400
    error_message = "share_quota_gb must be between 100 and 102400 GiB."
  }
}

variable "private_endpoint_subnet_id" {
  description = "(Required) Subnet ID for the Azure Files private endpoint."
  type        = string
}

variable "smb_contributor_principal_ids" {
  description = "(Optional) List of Entra principal IDs to assign Storage File Data SMB Share Contributor. Include session host VM managed identity principal IDs and optional user/group IDs."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics workspace resource ID for diagnostic settings."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "(Optional) When true and log_analytics_workspace_id is non-null, diagnostic settings are created."
  type        = bool
  default     = false
}

variable "diagnostic_log_category_group" {
  description = "(Optional) Diagnostic log category group. Only allLogs is supported for storage accounts."
  type        = string
  default     = "allLogs"

  validation {
    condition     = var.diagnostic_log_category_group == "allLogs"
    error_message = "diagnostic_log_category_group must be \"allLogs\" for storage accounts."
  }
}
