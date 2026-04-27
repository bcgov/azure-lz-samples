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

variable "scaling_plans" {
  description = "(Optional) Map of scaling plans to create. Each plan can reference one or more host pools."
  type = map(object({
    name           = string
    friendly_name  = optional(string)
    description    = optional(string)
    host_pool_type = optional(string) # Pooled or Personal; defaults to Pooled
    time_zone      = optional(string) # IANA or Windows time zone; defaults to "UTC"
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
}
