variable "name" {
  description = "(Required) Key Vault name."
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
  description = "(Optional) Tags to apply to the Key Vault and private endpoint."
  type        = map(string)
  default     = null
}

variable "tenant_id" {
  description = "(Required) Azure AD tenant ID for the Key Vault."
  type        = string
}

variable "deployer_object_id" {
  description = "(Required) Object ID of the principal running Terraform. Used to grant Key Vault Secrets Officer so secrets can be created when RBAC is enabled."
  type        = string
}

variable "sku_name" {
  description = "(Optional) SKU name. Must be 'standard' or 'premium'. Defaults to 'standard'."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be 'standard' or 'premium'."
  }
}

variable "enable_rbac_authorization" {
  description = "(Optional) Enable RBAC authorization for the Key Vault. Defaults to true. Note: argument will be renamed rbac_authorization_enabled in azurerm v5."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "(Optional) Enable purge protection. Defaults to true."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "(Optional) Soft-delete retention in days. Must be between 7 and 90. Defaults to 90."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "avd_local_admin_username" {
  description = "(Optional) Value stored in the AVD-Local-Admin-Username secret. Defaults to 'avdadmin'."
  type        = string
  default     = "avdadmin"

  validation {
    condition     = length(var.avd_local_admin_username) >= 1 && length(var.avd_local_admin_username) <= 20
    error_message = "avd_local_admin_username must be between 1 and 20 characters."
  }
}

variable "create_local_admin_secrets" {
  description = "(Optional) When true, create AVD-Local-Admin-Username and AVD-Local-Admin-Password secrets in this vault. Keep false until Terraform runs from approved private connectivity."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "(Required) Resource ID of the subnet where the Key Vault private endpoint will be created."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics Workspace resource ID for diagnostic settings. When set, logs are forwarded to the workspace."
  type        = string
  default     = null
}

variable "diagnostic_log_category_group" {
  description = "(Optional) Diagnostic log category group. Must be 'audit' or 'allLogs'. Defaults to 'audit'."
  type        = string
  default     = "audit"

  validation {
    condition     = contains(["audit", "allLogs"], var.diagnostic_log_category_group)
    error_message = "diagnostic_log_category_group must be 'audit' or 'allLogs'."
  }
}

variable "enable_diagnostics" {
  description = "(Optional) When true, diagnostic settings are created. Must be true only when log_analytics_workspace_id is also set. Separate bool keeps for_each keys known at plan time."
  type        = bool
  default     = false
}
