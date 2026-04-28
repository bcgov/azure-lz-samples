locals {
  # Resolves to the first LAW in the map (alphabetically by key); null when no workspaces defined.
  # Used to wire diagnostics across host pools, networking, and key vaults.
  avd_log_analytics_workspace_id = length(var.log_analytics_workspaces) > 0 ? module.log_analytics_workspaces[keys(var.log_analytics_workspaces)[0]].id : null

  workspace_application_group_associations = {
    for application_group_key, application_group in var.application_groups :
    "${application_group.workspace_key}.${application_group_key}" => {
      workspace_key         = application_group.workspace_key
      application_group_key = application_group_key
    } if try(application_group.workspace_key, null) != null
  }

  host_pool_defaults = {
    host_pool_type                  = "Pooled"
    preferred_app_group_type        = "Desktop"
    start_vm_on_connect             = true
    validation_environment          = false
    registration_token_operation    = "Update"
    registration_token_expiry_hours = 48
    use_session_host_configuration  = true
    agent_update = {
      type                         = "Scheduled"
      use_session_host_local_time  = false
      maintenance_window_time_zone = "UTC"
      maintenance_windows = [
        {
          day_of_week = "Sunday"
          hour        = 2
        }
      ]
    }
  }

  host_pools = {
    for key, host_pool in var.host_pools : key => {
      name           = host_pool.name
      friendly_name  = try(host_pool.friendly_name, null)
      description    = try(host_pool.description, null)
      host_pool_type = coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type)
      load_balancer_type = coalesce(
        try(host_pool.load_balancer_type, null),
        contains(["Personal", "BYODesktop"], coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type)) ? "Persistent" : "BreadthFirst"
      )
      personal_desktop_assignment_type = try(host_pool.personal_desktop_assignment_type, null) != null ? try(host_pool.personal_desktop_assignment_type, null) : (
        coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type) == "Personal" ? "Automatic" : (
          coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type) == "BYODesktop" ? "Direct" : null
        )
      )
      preferred_app_group_type = coalesce(try(host_pool.preferred_app_group_type, null), local.host_pool_defaults.preferred_app_group_type)
      max_session_limit = try(host_pool.max_session_limit, null) != null ? try(host_pool.max_session_limit, null) : (
        coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type) == "Pooled" ? 16 : null
      )
      start_vm_on_connect    = coalesce(try(host_pool.start_vm_on_connect, null), local.host_pool_defaults.start_vm_on_connect)
      validation_environment = coalesce(try(host_pool.validation_environment, null), local.host_pool_defaults.validation_environment)
      # If custom_rdp_properties is explicitly set use it as-is; otherwise build from rdp_properties with defaults.
      custom_rdp_properties = try(host_pool.custom_rdp_properties, null) != null ? host_pool.custom_rdp_properties : format("%s;", join(";", compact([
        coalesce(try(host_pool.rdp_properties.bulk_compression, null), true) ? "compression:i:1" : null,
        coalesce(try(host_pool.rdp_properties.network_auto_detect, null), true) ? "networkautodetect:i:1" : null,
        coalesce(try(host_pool.rdp_properties.bandwidth_auto_detect, null), true) ? "bandwidthautodetect:i:1" : null,
        coalesce(try(host_pool.rdp_properties.auto_reconnection, null), true) ? "autoreconnection enabled:i:1" : null,
        coalesce(try(host_pool.rdp_properties.entra_single_sign_on, null), true) ? "enablerdsaadauth:i:1" : null,
      ])))
      use_session_host_configuration  = coalesce(try(host_pool.use_session_host_configuration, null), local.host_pool_defaults.use_session_host_configuration)
      registration_token_operation    = coalesce(try(host_pool.registration_token_operation, null), local.host_pool_defaults.registration_token_operation)
      registration_token_expiry_hours = coalesce(try(host_pool.registration_token_expiry_hours, null), local.host_pool_defaults.registration_token_expiry_hours)
      agent_update = {
        type = coalesce(try(host_pool.agent_update.type, null), local.host_pool_defaults.agent_update.type)
        use_session_host_local_time = coalesce(
          try(host_pool.agent_update.use_session_host_local_time, null),
          local.host_pool_defaults.agent_update.use_session_host_local_time
        )
        maintenance_window_time_zone = coalesce(try(host_pool.agent_update.maintenance_window_time_zone, null), local.host_pool_defaults.agent_update.maintenance_window_time_zone)
        maintenance_windows = coalesce(
          try(host_pool.agent_update.maintenance_windows, null),
          local.host_pool_defaults.agent_update.maintenance_windows
        )
      }
    }
  }

  scaling_plans = {
    for key, plan in var.scaling_plans : key => {
      name           = plan.name
      friendly_name  = try(plan.friendly_name, null)
      description    = try(plan.description, null)
      host_pool_type = plan.host_pool_type
      time_zone      = plan.time_zone
      host_pool_references = [
        for reference in plan.host_pool_references : {
          host_pool_id = module.host_pools[reference.host_pool_key].id
          enabled      = reference.enabled
        }
      ]
      schedules = plan.schedules
    }
  }
}
