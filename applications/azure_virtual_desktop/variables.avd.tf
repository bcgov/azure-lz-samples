variable "host_pools" {
  description = "(Optional) Map of Azure Virtual Desktop host pools to create. The map key is the stable Terraform identity, so ordering changes in tfvars do not cause false plan changes."
  type = map(object({
    name                                  = string
    friendly_name                         = optional(string)
    description                           = optional(string)
    public_network_access                 = optional(string)
    deployment_scope                      = optional(string)
    management_type                       = optional(string)
    ring                                  = optional(number)
    vm_template                           = optional(string)
    allow_rdp_shortpath_with_private_link = optional(string)
    direct_udp                            = optional(string)
    managed_private_udp                   = optional(string)
    public_udp                            = optional(string)
    relay_udp                             = optional(string)
    host_pool_type                        = optional(string)
    load_balancer_type                    = optional(string)
    personal_desktop_assignment_type      = optional(string)
    preferred_app_group_type              = optional(string)
    max_session_limit                     = optional(number)
    start_vm_on_connect                   = optional(bool)
    validation_environment                = optional(bool)
    custom_rdp_properties                 = optional(string)
    rdp_properties = optional(object({
      entra_single_sign_on  = optional(bool) # enablerdsaadauth:i:1
      auto_reconnection     = optional(bool) # autoreconnection enabled:i:1
      bandwidth_auto_detect = optional(bool) # bandwidthautodetect:i:1
      network_auto_detect   = optional(bool) # networkautodetect:i:1
      bulk_compression      = optional(bool) # compression:i:1
      connections = optional(object({
        credential_security_support_provider = optional(string) # Disabled, EnabledIfSupported
      }))
      session_behavior = optional(object({
        video_playback_mode = optional(string) # Disabled, RdpEfficientWhenPossible
      }))
      device_redirection = optional(object({
        audio_capture                             = optional(bool)   # audiocapturemode:i:0|1
        audio_mode                                = optional(string) # PlayOnLocalDevice, PlayOnRemoteSession, DoNotPlay
        cameras                                   = optional(string) # camerastoredirect:s:<value>
        devices                                   = optional(string) # devicestoredirect:s:<value>
        drives                                    = optional(string) # drivestoredirect:s:<value>
        encode_redirected_video_capture           = optional(bool)   # encode redirected video capture:i:0|1
        keyboard_hook                             = optional(string) # Local, RemoteWhenInFocus, RemoteInFullScreen, RemoteAppWhenInFocus
        redirect_clipboard                        = optional(bool)   # redirectclipboard:i:0|1
        redirect_com_ports                        = optional(bool)   # redirectcomports:i:0|1
        redirected_video_capture_encoding_quality = optional(string) # HighCompression, MediumCompression, LowCompressionHighQuality
        redirect_location                         = optional(bool)   # redirectlocation:i:0|1
        redirect_printers                         = optional(bool)   # redirectprinters:i:0|1
        redirect_smart_cards                      = optional(bool)   # redirectsmartcards:i:0|1
        redirect_webauthn                         = optional(bool)   # redirectwebauthn:i:0|1
        usb_devices                               = optional(string) # usbdevicestoredirect:s:<value>
      }))
      display_settings = optional(object({
        desktop_size_id                 = optional(number) # desktop size id:i:0..4
        desktop_height                  = optional(number) # desktopheight:i:200..8192
        desktop_scale_factor            = optional(number) # desktopscalefactor:i:100|125|150|175|200|250|300|400|500
        desktop_width                   = optional(number) # desktopwidth:i:200..8192
        dynamic_resolution              = optional(bool)   # dynamic resolution:i:0|1
        maximize_to_current_displays    = optional(bool)   # maximizetocurrentdisplays:i:0|1
        screen_mode                     = optional(string) # Windowed, FullScreen
        selected_monitors               = optional(string) # selectedmonitors:s:<value>
        single_monitor_in_windowed_mode = optional(bool)   # singlemoninwindowedmode:i:0|1
        smart_sizing                    = optional(bool)   # smart sizing:i:0|1
        use_multimon                    = optional(bool)   # use multimon:i:0|1
      }))
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
    private_endpoints = optional(list(object({
      subnet_key        = string
      subresource_names = optional(list(string), ["connection"])
    })), [])
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

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Disabled", "Enabled", "EnabledForClientsOnly", "EnabledForSessionHostsOnly"], coalesce(try(host_pool.public_network_access, null), "Disabled")) &&
      contains(["Default", "Disabled", "Enabled"], coalesce(try(host_pool.public_udp, null), "Default")) &&
      contains(["Default", "Disabled", "Enabled"], coalesce(try(host_pool.relay_udp, null), "Default")) &&
      contains(["Default", "Disabled", "Enabled"], coalesce(try(host_pool.direct_udp, null), "Default")) &&
      contains(["Default", "Disabled", "Enabled"], coalesce(try(host_pool.managed_private_udp, null), "Default")) &&
      contains(["Disabled", "Enabled"], coalesce(try(host_pool.allow_rdp_shortpath_with_private_link, null), "Disabled")) &&
      contains(["Automated", "Standard"], coalesce(try(host_pool.management_type, null), "Standard")) &&
      contains(["Geographical", "Regional"], coalesce(try(host_pool.deployment_scope, null), "Regional"))
    ])
    error_message = "Host pool public access, UDP/Shortpath, management_type, and deployment_scope properties must use documented enum values."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      try(host_pool.ring, null) == null || host_pool.ring >= 0
    ])
    error_message = "Each host pool ring must be 0 or greater when set."
  }

  validation {
    condition = alltrue(flatten([
      for host_pool in values(var.host_pools) : [
        for private_endpoint in coalesce(try(host_pool.private_endpoints, null), []) :
        contains(keys(var.subnets), private_endpoint.subnet_key) || contains(keys(var.existing_subnet_ids), private_endpoint.subnet_key)
      ]
    ]))
    error_message = "Each host pool private_endpoints.subnet_key must reference a subnet key from subnets or existing_subnet_ids."
  }

  validation {
    condition = alltrue(flatten([
      for host_pool in values(var.host_pools) : [
        for private_endpoint in coalesce(try(host_pool.private_endpoints, null), []) :
        length(private_endpoint.subresource_names) > 0
      ]
    ]))
    error_message = "Each host pool private endpoint must define at least one subresource name."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Disabled", "EnabledIfSupported"], coalesce(try(host_pool.rdp_properties.connections.credential_security_support_provider, null), "EnabledIfSupported"))
    ])
    error_message = "Each host pool rdp_properties.connections.credential_security_support_provider must be Disabled or EnabledIfSupported."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["Disabled", "RdpEfficientWhenPossible"], coalesce(try(host_pool.rdp_properties.session_behavior.video_playback_mode, null), "RdpEfficientWhenPossible"))
    ])
    error_message = "Each host pool rdp_properties.session_behavior.video_playback_mode must be Disabled or RdpEfficientWhenPossible."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains(["PlayOnLocalDevice", "PlayOnRemoteSession", "DoNotPlay"], coalesce(try(host_pool.rdp_properties.device_redirection.audio_mode, null), "PlayOnLocalDevice")) &&
      contains(["Local", "RemoteWhenInFocus", "RemoteInFullScreen", "RemoteAppWhenInFocus"], coalesce(try(host_pool.rdp_properties.device_redirection.keyboard_hook, null), "RemoteInFullScreen")) &&
      contains(["HighCompression", "MediumCompression", "LowCompressionHighQuality"], coalesce(try(host_pool.rdp_properties.device_redirection.redirected_video_capture_encoding_quality, null), "HighCompression")) &&
      contains(["Windowed", "FullScreen"], coalesce(try(host_pool.rdp_properties.display_settings.screen_mode, null), "FullScreen"))
    ])
    error_message = "Host pool device redirection and display settings must use the documented enum values."
  }

  validation {
    condition = alltrue([
      for host_pool in values(var.host_pools) :
      contains([0, 1, 2, 3, 4], coalesce(try(host_pool.rdp_properties.display_settings.desktop_size_id, null), 0)) &&
      contains([100, 125, 150, 175, 200, 250, 300, 400, 500], coalesce(try(host_pool.rdp_properties.display_settings.desktop_scale_factor, null), 100)) &&
      coalesce(try(host_pool.rdp_properties.display_settings.desktop_width, null), 200) >= 200 &&
      coalesce(try(host_pool.rdp_properties.display_settings.desktop_width, null), 200) <= 8192 &&
      coalesce(try(host_pool.rdp_properties.display_settings.desktop_height, null), 200) >= 200 &&
      coalesce(try(host_pool.rdp_properties.display_settings.desktop_height, null), 200) <= 8192
    ])
    error_message = "Host pool display settings must use supported desktop_size_id, desktop_scale_factor, desktop_width, and desktop_height values when set."
  }
}

variable "scaling_plans" {
  description = "(Optional) Map of Azure Virtual Desktop scaling plans. Each plan references host pools by key from host_pools."
  type = map(object({
    name                          = string
    friendly_name                 = optional(string)
    description                   = optional(string)
    exclusion_tag                 = optional(string)
    host_pool_type                = optional(string, "Pooled")
    time_zone                     = optional(string, "UTC")
    diagnostic_log_category_group = optional(string, "allLogs")
    host_pool_references = optional(list(object({
      host_pool_key = string
      enabled       = optional(bool, true)
    })), [])
    schedules = optional(list(any), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for plan in values(var.scaling_plans) :
      contains(["Pooled", "Personal"], plan.host_pool_type)
    ])
    error_message = "Each scaling plan host_pool_type must be Pooled or Personal."
  }

  validation {
    condition = alltrue(flatten([
      for plan in values(var.scaling_plans) : [
        for reference in plan.host_pool_references :
        contains(keys(var.host_pools), reference.host_pool_key)
      ]
    ]))
    error_message = "Each scaling plan host_pool_references.host_pool_key must reference an existing key in host_pools."
  }

  validation {
    condition = alltrue([
      for plan in values(var.scaling_plans) :
      coalesce(try(plan.diagnostic_log_category_group, null), "allLogs") == "allLogs"
    ])
    error_message = "Each scaling plan diagnostic_log_category_group must be allLogs."
  }
}

variable "session_hosts" {
  description = "(Optional) Map of Azure VM-based AVD session host definitions. Each entry can create one or more Microsoft Entra joined Windows session hosts and register them to a standard-management host pool."
  type = map(object({
    host_pool_key                = string
    subnet_key                   = string
    instance_count               = optional(number, 1)
    vm_name_prefix               = optional(string)
    computer_name_prefix         = optional(string)
    size                         = optional(string, "Standard_D4ds_v4")
    join_type                    = optional(string, "MicrosoftEntraJoined")
    admin_username               = optional(string, "avdadmin")
    admin_password               = optional(string)
    license_type                 = optional(string, "Windows_Client")
    os_disk_storage_account_type = optional(string, "StandardSSD_LRS")
    os_disk_size_gb              = optional(number) # Override OS disk size in GB; leave null to use image default.
    diff_disk_settings = optional(object({          # Ephemeral OS disk. Not compatible with os_disk_size_gb.
      option    = string                            # CacheDisk or NvmeDisk
      placement = optional(string)                  # CacheDisk or ResourceDisk
    }))
    accelerated_networking_enabled       = optional(bool, false)       # Requires a VM size that supports AN.
    availability_zone                    = optional(number)            # 1, 2, or 3. Leave null to let Azure choose.
    enable_boot_diagnostics              = optional(bool, true)        # Managed boot diagnostics by default.
    boot_diagnostics_storage_account_uri = optional(string)            # Override with a specific storage account URI.
    extensions_time_budget               = optional(string, "PT1H30M") # ISO 8601 duration budget for all extensions.
    enable_integrity_monitoring          = optional(bool, true)        # Guest attestation integrity monitoring for Trusted Launch VMs.
    patch_mode                           = optional(string, "AutomaticByOS")
    enable_automatic_updates             = optional(bool, true)
    provision_vm_agent                   = optional(bool, true)
    secure_boot_enabled                  = optional(bool, true)
    vtpm_enabled                         = optional(bool, true)
    source_image_id                      = optional(string)
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    }))
    vm_role_assignments = optional(map(object({
      principal_id         = string
      principal_type       = optional(string)
      role_definition_name = optional(string, "Virtual Machine User Login")
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      contains(keys(var.host_pools), session_host.host_pool_key)
    ])
    error_message = "Each session_hosts.host_pool_key must reference an existing key in host_pools."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      contains(keys(var.subnets), session_host.subnet_key) || contains(keys(var.existing_subnet_ids), session_host.subnet_key)
    ])
    error_message = "Each session_hosts.subnet_key must reference a subnet key from subnets or existing_subnet_ids."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      coalesce(try(session_host.instance_count, null), 1) >= 1 && coalesce(try(session_host.instance_count, null), 1) <= 99
    ])
    error_message = "Each session_hosts.instance_count must be between 1 and 99."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      coalesce(try(session_host.join_type, null), "MicrosoftEntraJoined") == "MicrosoftEntraJoined"
    ])
    error_message = "This module currently supports only MicrosoftEntraJoined session hosts."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      try(session_host.vm_name_prefix, null) == null || can(regex("^[A-Za-z0-9-]{1,58}$", session_host.vm_name_prefix))
    ])
    error_message = "Each session_hosts.vm_name_prefix must use only letters, numbers, and hyphens and stay within 58 characters when set."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      try(session_host.computer_name_prefix, null) == null || can(regex("^[A-Za-z0-9-]{1,13}$", session_host.computer_name_prefix))
    ])
    error_message = "Each session_hosts.computer_name_prefix must use only letters, numbers, and hyphens and stay within 13 characters when set."
  }

  validation {
    condition = alltrue([
      for session_host in values(var.session_hosts) :
      !(try(session_host.source_image_id, null) != null && try(session_host.source_image_reference, null) != null)
    ])
    error_message = "Each session_hosts entry can set either source_image_id or source_image_reference, but not both."
  }
}
