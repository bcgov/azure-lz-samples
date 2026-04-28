variable "resource_group_id" {
  description = "(Required) The resource group ID where the host pool will be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The resource group name where the host pool will be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure region for the host pool."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags to apply to the host pool."
  type        = map(string)
  default     = null
}

variable "host_pool_name" {
  description = "(Required) Base host pool name before the random suffix is appended."
  type        = string
}

variable "friendly_name" {
  description = "(Optional) Friendly display name for the host pool."
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional) Description for the host pool."
  type        = string
  default     = null
}

variable "public_network_access" {
  description = "(Optional) Public network access mode for the host pool."
  type        = string
  default     = "Disabled"
}

variable "deployment_scope" {
  description = "(Optional) Deployment scope for the host pool."
  type        = string
  default     = "Geographical"
}

variable "management_type" {
  description = "(Optional) Host pool management type."
  type        = string
  default     = "Standard"
}

variable "ring" {
  description = "(Optional) Ring number for the host pool."
  type        = number
  default     = null
}

variable "vm_template" {
  description = "(Optional) VM template JSON for session host configuration scenarios."
  type        = string
  default     = null
}

variable "allow_rdp_shortpath_with_private_link" {
  description = "(Optional) Whether RDP Shortpath with Private Link is allowed."
  type        = string
  default     = "Disabled"
}

variable "direct_udp" {
  description = "(Optional) Direct UDP transport setting."
  type        = string
  default     = "Default"
}

variable "managed_private_udp" {
  description = "(Optional) Managed private UDP transport setting."
  type        = string
  default     = "Default"
}

variable "public_udp" {
  description = "(Optional) Public UDP/STUN transport setting."
  type        = string
  default     = "Default"
}

variable "relay_udp" {
  description = "(Optional) Relay/TURN UDP transport setting."
  type        = string
  default     = "Default"
}

variable "host_pool_type" {
  description = "(Required) Host pool type."
  type        = string
}

variable "load_balancer_type" {
  description = "(Required) Load balancer type."
  type        = string
}

variable "personal_desktop_assignment_type" {
  description = "(Optional) Personal desktop assignment type for Personal or BYODesktop pools."
  type        = string
  default     = null
}

variable "preferred_app_group_type" {
  description = "(Required) Preferred application group type."
  type        = string
}

variable "max_session_limit" {
  description = "(Optional) Maximum number of sessions per session host."
  type        = number
  default     = null
}

variable "start_vm_on_connect" {
  description = "(Optional) Enable Start VM on Connect."
  type        = bool
}

variable "validation_environment" {
  description = "(Optional) Whether the host pool is a validation environment."
  type        = bool
}

variable "custom_rdp_properties" {
  description = "(Optional) Custom RDP properties."
  type        = string
  default     = null
}

variable "registration_token_operation" {
  description = "(Required) Registration token operation."
  type        = string
}

variable "registration_token_expiry_hours" {
  description = "(Required) Registration token expiration in hours."
  type        = number
}

variable "agent_update_type" {
  description = "(Required) Agent update type."
  type        = string
}

variable "agent_update_use_session_host_local_time" {
  description = "(Optional) Whether scheduled agent updates use the session host local time."
  type        = bool
}

variable "agent_update_maintenance_window_time_zone" {
  description = "(Optional) Time zone for scheduled maintenance windows."
  type        = string
  default     = null
}

variable "agent_update_maintenance_windows" {
  description = "(Optional) Scheduled agent update maintenance windows."
  type = list(object({
    day_of_week = string
    hour        = number
  }))
  default = []
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

variable "private_endpoints" {
  description = "(Optional) Private endpoints to create for the host pool."
  type = list(object({
    subnet_id         = string
    subresource_names = list(string)
  }))
  default = []
}
