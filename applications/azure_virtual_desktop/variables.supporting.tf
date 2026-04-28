variable "log_analytics_workspaces" {
  description = "(Optional) Log Analytics Workspaces to create. All other resources with diagnostics enabled will forward logs to the first workspace in this map unless a specific key is specified."
  type = map(object({
    name                          = string
    sku                           = optional(string, "PerGB2018")
    retention_in_days             = optional(number, 30)
    daily_quota_gb                = optional(number, -1)
    diagnostic_log_category_group = optional(string, "audit")
  }))
  default = {}
}

variable "manage_diagnostic_settings" {
  description = "(Optional) When true, this module creates resource diagnostic settings. Set false when diagnostics are deployed by policy to avoid create/import conflicts."
  type        = bool
  default     = true
}

variable "key_vaults" {
  description = "(Optional) Key Vaults to create. Each vault gets a private endpoint, optional AVD local-admin secrets, and optional diagnostic forwarding."
  type = map(object({
    name                       = string
    sku_name                   = optional(string, "standard")
    enable_rbac_authorization  = optional(bool, true)
    purge_protection_enabled   = optional(bool, true)
    soft_delete_retention_days = optional(number, 90)
    avd_local_admin_username   = optional(string, "avdadmin")
    create_local_admin_secrets = optional(bool, false)
    # Key from networking subnet_ids (created or existing) used for the private endpoint.
    private_endpoint_subnet_key   = string
    diagnostic_log_category_group = optional(string, "audit")
  }))
  default = {}
}
