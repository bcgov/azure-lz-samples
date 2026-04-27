variable "host_pools" {
  description = "(Optional) Map of Azure Virtual Desktop host pools to create. The map key is the stable Terraform identity, so ordering changes in tfvars do not cause false plan changes."
  type = map(object({
    name                             = string
    friendly_name                    = optional(string)
    description                      = optional(string)
    host_pool_type                   = optional(string)
    load_balancer_type               = optional(string)
    personal_desktop_assignment_type = optional(string)
    preferred_app_group_type         = optional(string)
    max_session_limit                = optional(number)
    start_vm_on_connect              = optional(bool)
    validation_environment           = optional(bool)
    custom_rdp_properties            = optional(string)
    rdp_properties = optional(object({
      entra_single_sign_on  = optional(bool) # enablerdsaadauth:i:1
      auto_reconnection     = optional(bool) # autoreconnection enabled:i:1
      bandwidth_auto_detect = optional(bool) # bandwidthautodetect:i:1
      network_auto_detect   = optional(bool) # networkautodetect:i:1
      bulk_compression      = optional(bool) # compression:i:1
    }))
    use_session_host_configuration  = optional(bool) # reserved: requires managementType=Automated; scaffold only
    registration_token_operation    = optional(string)
    registration_token_expiry_hours = optional(number)
    agent_update = optional(object({
      type                         = optional(string)
      use_session_host_local_time  = optional(bool)
      maintenance_window_time_zone = optional(string)
      maintenance_windows = optional(list(object({
        day_of_week = string
        hour        = number
      })))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      length(host_pool.name) >= 3 &&
      length(host_pool.name) <= 57 &&
      can(regex("^[A-Za-z0-9@._ -]+$", host_pool.name))
    ])
    error_message = "Each host_pools value must have a name between 3 and 57 characters containing only letters, numbers, spaces, '@', '.', '-', and '_'."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Pooled", "Personal", "BYODesktop"], coalesce(try(host_pool.host_pool_type, null), "Pooled"))
    ])
    error_message = "Each host pool host_pool_type must be one of: Pooled, Personal, BYODesktop."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      (
        coalesce(try(host_pool.host_pool_type, null), "Pooled") == "Pooled" &&
        contains(["BreadthFirst", "DepthFirst"], coalesce(try(host_pool.load_balancer_type, null), "BreadthFirst"))
        ) || (
        contains(["Personal", "BYODesktop"], coalesce(try(host_pool.host_pool_type, null), "Pooled")) &&
        coalesce(try(host_pool.load_balancer_type, null), "Persistent") == "Persistent"
      )
    ])
    error_message = "Each host pool must use BreadthFirst or DepthFirst for Pooled and Persistent for Personal or BYODesktop."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      (
        coalesce(try(host_pool.host_pool_type, null), "Pooled") == "Pooled" && try(host_pool.personal_desktop_assignment_type, null) == null
        ) || (
        coalesce(try(host_pool.host_pool_type, null), "Pooled") == "Personal" && contains(["Automatic", "Direct"], coalesce(try(host_pool.personal_desktop_assignment_type, null), "Automatic"))
        ) || (
        coalesce(try(host_pool.host_pool_type, null), "Pooled") == "BYODesktop" && coalesce(try(host_pool.personal_desktop_assignment_type, null), "Direct") == "Direct"
      )
    ])
    error_message = "Each host pool must use a valid personal_desktop_assignment_type for its host_pool_type."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Desktop", "RailApplications", "None"], coalesce(try(host_pool.preferred_app_group_type, null), "Desktop"))
    ])
    error_message = "Each host pool preferred_app_group_type must be one of: Desktop, RailApplications, None."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      try(host_pool.max_session_limit, null) == null || (host_pool.max_session_limit >= 1 && host_pool.max_session_limit <= 999999)
    ])
    error_message = "Each host pool max_session_limit must be between 1 and 999999 when set."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Delete", "None", "Update"], coalesce(try(host_pool.registration_token_operation, null), "Update"))
    ])
    error_message = "Each host pool registration_token_operation must be one of: Delete, None, Update."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      coalesce(try(host_pool.registration_token_expiry_hours, null), 48) >= 1 && coalesce(try(host_pool.registration_token_expiry_hours, null), 48) <= 720
    ])
    error_message = "Each host pool registration_token_expiry_hours must be between 1 and 720."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Default", "Scheduled"], coalesce(try(host_pool.agent_update.type, null), "Default"))
    ])
    error_message = "Each host pool agent_update.type must be Default or Scheduled."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      coalesce(try(host_pool.agent_update.type, null), "Default") == "Default" || length(coalesce(try(host_pool.agent_update.maintenance_windows, null), [])) > 0
    ])
    error_message = "Each host pool with Scheduled agent updates must define at least one maintenance window."
  }

  validation {
    condition = alltrue(flatten([
      for host_pool in values(var.host_pools) : [
        for window in coalesce(try(host_pool.agent_update.maintenance_windows, null), []) :
        contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], window.day_of_week) && window.hour >= 0 && window.hour <= 23
      ]
    ]))
    error_message = "Each agent update maintenance window must use a valid day_of_week and an hour between 0 and 23."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      coalesce(try(host_pool.agent_update.type, null), "Default") == "Default" ||
      coalesce(try(host_pool.agent_update.use_session_host_local_time, null), false) == false ||
      trim(coalesce(try(host_pool.agent_update.maintenance_window_time_zone, null), "")) != ""
    ])
    error_message = "Each Scheduled agent update that uses session host local time must define maintenance_window_time_zone."
  }
}
