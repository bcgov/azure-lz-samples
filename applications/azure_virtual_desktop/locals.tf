locals {
  credential_security_support_provider_codes = {
    Disabled           = 0
    EnabledIfSupported = 1
  }

  video_playback_mode_codes = {
    Disabled                 = 0
    RdpEfficientWhenPossible = 1
  }

  audio_mode_codes = {
    PlayOnLocalDevice   = 0
    PlayOnRemoteSession = 1
    DoNotPlay           = 2
  }

  keyboard_hook_codes = {
    Local                = 0
    RemoteWhenInFocus    = 1
    RemoteInFullScreen   = 2
    RemoteAppWhenInFocus = 3
  }

  redirected_video_capture_encoding_quality_codes = {
    HighCompression           = 0
    MediumCompression         = 1
    LowCompressionHighQuality = 2
  }

  screen_mode_codes = {
    Windowed   = 1
    FullScreen = 2
  }

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
    host_pool_type                        = "Pooled"
    preferred_app_group_type              = "Desktop"
    public_network_access                 = "Disabled"
    deployment_scope                      = "Geographical"
    management_type                       = "Standard"
    allow_rdp_shortpath_with_private_link = "Disabled"
    direct_udp                            = "Default"
    managed_private_udp                   = "Default"
    public_udp                            = "Default"
    relay_udp                             = "Default"
    start_vm_on_connect                   = true
    validation_environment                = false
    registration_token_operation          = "Update"
    registration_token_expiry_hours       = 48
    use_session_host_configuration        = true
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
      name                                  = host_pool.name
      friendly_name                         = try(host_pool.friendly_name, null)
      description                           = try(host_pool.description, null)
      public_network_access                 = coalesce(try(host_pool.public_network_access, null), local.host_pool_defaults.public_network_access)
      deployment_scope                      = coalesce(try(host_pool.deployment_scope, null), local.host_pool_defaults.deployment_scope)
      management_type                       = coalesce(try(host_pool.management_type, null), local.host_pool_defaults.management_type)
      ring                                  = try(host_pool.ring, null)
      vm_template                           = try(host_pool.vm_template, null)
      allow_rdp_shortpath_with_private_link = coalesce(try(host_pool.allow_rdp_shortpath_with_private_link, null), local.host_pool_defaults.allow_rdp_shortpath_with_private_link)
      direct_udp                            = coalesce(try(host_pool.direct_udp, null), local.host_pool_defaults.direct_udp)
      managed_private_udp                   = coalesce(try(host_pool.managed_private_udp, null), local.host_pool_defaults.managed_private_udp)
      public_udp                            = coalesce(try(host_pool.public_udp, null), local.host_pool_defaults.public_udp)
      relay_udp                             = coalesce(try(host_pool.relay_udp, null), local.host_pool_defaults.relay_udp)
      host_pool_type                        = coalesce(try(host_pool.host_pool_type, null), local.host_pool_defaults.host_pool_type)
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
      custom_rdp_properties = try(host_pool.custom_rdp_properties, null) != null ? host_pool.custom_rdp_properties : format("%s;", join(";", compact(concat(
        [
          format("compression:i:%d", coalesce(try(host_pool.rdp_properties.bulk_compression, null), true) ? 1 : 0),
          format("networkautodetect:i:%d", coalesce(try(host_pool.rdp_properties.network_auto_detect, null), true) ? 1 : 0),
          format("bandwidthautodetect:i:%d", coalesce(try(host_pool.rdp_properties.bandwidth_auto_detect, null), true) ? 1 : 0),
          format("autoreconnection enabled:i:%d", coalesce(try(host_pool.rdp_properties.auto_reconnection, null), true) ? 1 : 0),
          format("enablerdsaadauth:i:%d", coalesce(try(host_pool.rdp_properties.entra_single_sign_on, null), true) ? 1 : 0),
          format("enablecredsspsupport:i:%d", local.credential_security_support_provider_codes[coalesce(try(host_pool.rdp_properties.connections.credential_security_support_provider, null), "EnabledIfSupported")]),
          format("videoplaybackmode:i:%d", local.video_playback_mode_codes[coalesce(try(host_pool.rdp_properties.session_behavior.video_playback_mode, null), "RdpEfficientWhenPossible")]),
        ],
        [
          try(host_pool.rdp_properties.device_redirection.audio_capture, null) == null ? null : format("audiocapturemode:i:%d", host_pool.rdp_properties.device_redirection.audio_capture ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.audio_mode, null) == null ? null : format("audiomode:i:%d", local.audio_mode_codes[host_pool.rdp_properties.device_redirection.audio_mode]),
          try(host_pool.rdp_properties.device_redirection.cameras, null) == null ? null : format("camerastoredirect:s:%s", host_pool.rdp_properties.device_redirection.cameras),
          try(host_pool.rdp_properties.device_redirection.devices, null) == null ? null : format("devicestoredirect:s:%s", host_pool.rdp_properties.device_redirection.devices),
          try(host_pool.rdp_properties.device_redirection.drives, null) == null ? null : format("drivestoredirect:s:%s", host_pool.rdp_properties.device_redirection.drives),
          try(host_pool.rdp_properties.device_redirection.encode_redirected_video_capture, null) == null ? null : format("encode redirected video capture:i:%d", host_pool.rdp_properties.device_redirection.encode_redirected_video_capture ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.keyboard_hook, null) == null ? null : format("keyboardhook:i:%d", local.keyboard_hook_codes[host_pool.rdp_properties.device_redirection.keyboard_hook]),
          try(host_pool.rdp_properties.device_redirection.redirect_clipboard, null) == null ? null : format("redirectclipboard:i:%d", host_pool.rdp_properties.device_redirection.redirect_clipboard ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.redirect_com_ports, null) == null ? null : format("redirectcomports:i:%d", host_pool.rdp_properties.device_redirection.redirect_com_ports ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.redirected_video_capture_encoding_quality, null) == null ? null : format("redirected video capture encoding quality:i:%d", local.redirected_video_capture_encoding_quality_codes[host_pool.rdp_properties.device_redirection.redirected_video_capture_encoding_quality]),
          try(host_pool.rdp_properties.device_redirection.redirect_location, null) == null ? null : format("redirectlocation:i:%d", host_pool.rdp_properties.device_redirection.redirect_location ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.redirect_printers, null) == null ? null : format("redirectprinters:i:%d", host_pool.rdp_properties.device_redirection.redirect_printers ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.redirect_smart_cards, null) == null ? null : format("redirectsmartcards:i:%d", host_pool.rdp_properties.device_redirection.redirect_smart_cards ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.redirect_webauthn, null) == null ? null : format("redirectwebauthn:i:%d", host_pool.rdp_properties.device_redirection.redirect_webauthn ? 1 : 0),
          try(host_pool.rdp_properties.device_redirection.usb_devices, null) == null ? null : format("usbdevicestoredirect:s:%s", host_pool.rdp_properties.device_redirection.usb_devices),
        ],
        [
          try(host_pool.rdp_properties.display_settings.desktop_size_id, null) == null ? null : format("desktop size id:i:%d", host_pool.rdp_properties.display_settings.desktop_size_id),
          try(host_pool.rdp_properties.display_settings.desktop_height, null) == null ? null : format("desktopheight:i:%d", host_pool.rdp_properties.display_settings.desktop_height),
          try(host_pool.rdp_properties.display_settings.desktop_scale_factor, null) == null ? null : format("desktopscalefactor:i:%d", host_pool.rdp_properties.display_settings.desktop_scale_factor),
          try(host_pool.rdp_properties.display_settings.desktop_width, null) == null ? null : format("desktopwidth:i:%d", host_pool.rdp_properties.display_settings.desktop_width),
          try(host_pool.rdp_properties.display_settings.dynamic_resolution, null) == null ? null : format("dynamic resolution:i:%d", host_pool.rdp_properties.display_settings.dynamic_resolution ? 1 : 0),
          try(host_pool.rdp_properties.display_settings.maximize_to_current_displays, null) == null ? null : format("maximizetocurrentdisplays:i:%d", host_pool.rdp_properties.display_settings.maximize_to_current_displays ? 1 : 0),
          try(host_pool.rdp_properties.display_settings.screen_mode, null) == null ? null : format("screen mode id:i:%d", local.screen_mode_codes[host_pool.rdp_properties.display_settings.screen_mode]),
          try(host_pool.rdp_properties.display_settings.selected_monitors, null) == null ? null : format("selectedmonitors:s:%s", host_pool.rdp_properties.display_settings.selected_monitors),
          try(host_pool.rdp_properties.display_settings.single_monitor_in_windowed_mode, null) == null ? null : format("singlemoninwindowedmode:i:%d", host_pool.rdp_properties.display_settings.single_monitor_in_windowed_mode ? 1 : 0),
          try(host_pool.rdp_properties.display_settings.smart_sizing, null) == null ? null : format("smart sizing:i:%d", host_pool.rdp_properties.display_settings.smart_sizing ? 1 : 0),
          try(host_pool.rdp_properties.display_settings.use_multimon, null) == null ? null : format("use multimon:i:%d", host_pool.rdp_properties.display_settings.use_multimon ? 1 : 0),
        ]
      ))))
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
      private_endpoints = [
        for private_endpoint in coalesce(try(host_pool.private_endpoints, null), []) : {
          subnet_id         = contains(keys(var.subnets), private_endpoint.subnet_key) ? module.networking.subnet_ids[private_endpoint.subnet_key] : var.existing_subnet_ids[private_endpoint.subnet_key]
          subresource_names = coalesce(try(private_endpoint.subresource_names, null), ["connection"])
        }
      ]
    }
  }

  session_host_defaults = {
    instance_count                       = 1
    size                                 = "Standard_D4ds_v4"
    join_type                            = "MicrosoftEntraJoined"
    admin_username                       = "avdadmin"
    license_type                         = "Windows_Client"
    os_disk_storage_account_type         = "StandardSSD_LRS"
    patch_mode                           = "AutomaticByOS"
    enable_automatic_updates             = true
    provision_vm_agent                   = true
    secure_boot_enabled                  = true
    vtpm_enabled                         = true
    os_disk_size_gb                      = null
    diff_disk_settings                   = null
    accelerated_networking_enabled       = false
    availability_zone                    = null
    enable_boot_diagnostics              = true
    boot_diagnostics_storage_account_uri = null
    extensions_time_budget               = "PT1H30M"
    enable_integrity_monitoring          = true
    source_image_reference = {
      publisher = "MicrosoftWindowsDesktop"
      offer     = "office-365"
      sku       = "win11-24h2-avd-m365"
      version   = "latest"
    }
    vm_role_assignments = {}
    tags                = {}
    # FSLogix share paths default to null; resolved at instance projection time.
    fslogix_profile_share_paths = null
  }

  session_host_instances = length(var.session_hosts) == 0 ? {} : merge([
    for session_host_key, session_host in var.session_hosts : {
      for index in range(coalesce(try(session_host.instance_count, null), local.session_host_defaults.instance_count)) : format("%s.%02d", session_host_key, index + 1) => {
        host_pool_key                        = session_host.host_pool_key
        host_pool_id                         = module.host_pools[session_host.host_pool_key].id
        host_pool_registration_token         = module.host_pools[session_host.host_pool_key].registration_token
        subnet_id                            = contains(keys(var.subnets), session_host.subnet_key) ? module.networking.subnet_ids[session_host.subnet_key] : var.existing_subnet_ids[session_host.subnet_key]
        vm_name                              = format("%s-%02d", coalesce(try(session_host.vm_name_prefix, null), replace(lower(session_host_key), "/[^0-9a-z-]/", "-")), index + 1)
        computer_name                        = format("%s%02d", substr(coalesce(try(session_host.computer_name_prefix, null), replace(lower(session_host_key), "/[^0-9a-z]/", "")), 0, 13), index + 1)
        size                                 = coalesce(try(session_host.size, null), local.session_host_defaults.size)
        join_type                            = coalesce(try(session_host.join_type, null), local.session_host_defaults.join_type)
        admin_username                       = coalesce(try(session_host.admin_username, null), local.session_host_defaults.admin_username)
        admin_password                       = try(session_host.admin_password, null)
        license_type                         = coalesce(try(session_host.license_type, null), local.session_host_defaults.license_type)
        os_disk_storage_account_type         = coalesce(try(session_host.os_disk_storage_account_type, null), local.session_host_defaults.os_disk_storage_account_type)
        patch_mode                           = coalesce(try(session_host.patch_mode, null), local.session_host_defaults.patch_mode)
        enable_automatic_updates             = coalesce(try(session_host.enable_automatic_updates, null), local.session_host_defaults.enable_automatic_updates)
        provision_vm_agent                   = coalesce(try(session_host.provision_vm_agent, null), local.session_host_defaults.provision_vm_agent)
        secure_boot_enabled                  = coalesce(try(session_host.secure_boot_enabled, null), local.session_host_defaults.secure_boot_enabled)
        vtpm_enabled                         = coalesce(try(session_host.vtpm_enabled, null), local.session_host_defaults.vtpm_enabled)
        os_disk_size_gb                      = try(session_host.os_disk_size_gb, local.session_host_defaults.os_disk_size_gb)
        diff_disk_settings                   = try(session_host.diff_disk_settings, local.session_host_defaults.diff_disk_settings)
        accelerated_networking_enabled       = coalesce(try(session_host.accelerated_networking_enabled, null), local.session_host_defaults.accelerated_networking_enabled)
        availability_zone                    = try(session_host.availability_zone, local.session_host_defaults.availability_zone)
        enable_boot_diagnostics              = coalesce(try(session_host.enable_boot_diagnostics, null), local.session_host_defaults.enable_boot_diagnostics)
        boot_diagnostics_storage_account_uri = try(session_host.boot_diagnostics_storage_account_uri, local.session_host_defaults.boot_diagnostics_storage_account_uri)
        extensions_time_budget               = coalesce(try(session_host.extensions_time_budget, null), local.session_host_defaults.extensions_time_budget)
        enable_integrity_monitoring          = coalesce(try(session_host.enable_integrity_monitoring, null), local.session_host_defaults.enable_integrity_monitoring)
        source_image_id                      = try(session_host.source_image_id, null)
        source_image_reference = try(session_host.source_image_reference, null) != null ? {
          publisher = session_host.source_image_reference.publisher
          offer     = session_host.source_image_reference.offer
          sku       = session_host.source_image_reference.sku
          version   = coalesce(try(session_host.source_image_reference.version, null), "latest")
        } : local.session_host_defaults.source_image_reference
        vm_role_assignments = coalesce(try(session_host.vm_role_assignments, null), local.session_host_defaults.vm_role_assignments)
        tags                = merge(var.tags == null ? {} : var.tags, coalesce(try(session_host.tags, null), local.session_host_defaults.tags))
        # Optional per-group FSLogix share path override. When null, the root
        # fslogix_storage module share path is used in main.tf.
        fslogix_profile_share_paths = try(session_host.fslogix_profile_share_paths, null)
      }
    }
  ]...)

  workspace_private_endpoints = {
    for workspace_key, workspace in var.workspaces : workspace_key => {
      for private_endpoint_key, private_endpoint in {
        for index, definition in coalesce(try(workspace.private_endpoints, null), []) : tostring(index) => definition
        } : private_endpoint_key => {
        subnet_id         = contains(keys(var.subnets), private_endpoint.subnet_key) ? module.networking.subnet_ids[private_endpoint.subnet_key] : var.existing_subnet_ids[private_endpoint.subnet_key]
        subresource_names = coalesce(try(private_endpoint.subresource_names, null), ["feed"])
      }
    }
  }

  scaling_plans = {
    for key, plan in var.scaling_plans : key => {
      name                          = plan.name
      friendly_name                 = try(plan.friendly_name, null)
      description                   = try(plan.description, null)
      exclusion_tag                 = try(plan.exclusion_tag, null)
      host_pool_type                = plan.host_pool_type
      time_zone                     = plan.time_zone
      diagnostic_log_category_group = coalesce(try(plan.diagnostic_log_category_group, null), "allLogs")
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
