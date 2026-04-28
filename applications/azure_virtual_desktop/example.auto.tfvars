resource_group_name                 = "e833c2-dev-avd"
location                            = "canadacentral"
virtual_network_name                = "e833c2-dev-vwan-spoke"
virtual_network_resource_group_name = "e833c2-dev-networking"

host_pools = {
  pooled_primary = {
    name                   = "e833c2-avd-hostpool"
    validation_environment = false
    public_network_access  = "Disabled"
    private_endpoints = [
      {
        subnet_key        = "avd_private_endpoints"
        subresource_names = ["connection"]
      }
    ]
  }

  # validation_and_shortpath_example = {
  #   name                             = "e833c2-avd-validation"
  #   validation_environment           = true
  #   public_network_access            = "Enabled"
  #   public_udp                       = "Enabled" # RDP Shortpath for public networks (via STUN)
  #   relay_udp                        = "Enabled" # RDP Shortpath for public networks (via TURN/Relay)
  #   direct_udp                       = "Enabled"
  #   managed_private_udp              = "Default"
  #   allow_rdp_shortpath_with_private_link = "Disabled"
  # }

  # rdp_properties_example = {
  #   name = "e833c2-avd-rdp-example"
  #   rdp_properties = {
  #     connections = {
  #       credential_security_support_provider = "EnabledIfSupported"
  #     }
  #     session_behavior = {
  #       video_playback_mode = "RdpEfficientWhenPossible"
  #     }
  #     device_redirection = {
  #       audio_capture                             = true
  #       audio_mode                                = "PlayOnLocalDevice"
  #       cameras                                   = "*"
  #       devices                                   = "DynamicDevices"
  #       drives                                    = "DynamicDrives"
  #       encode_redirected_video_capture           = true
  #       keyboard_hook                             = "RemoteInFullScreen"
  #       redirect_clipboard                        = true
  #       redirect_com_ports                        = true
  #       redirected_video_capture_encoding_quality = "MediumCompression"
  #       redirect_location                         = true
  #       redirect_printers                         = true
  #       redirect_smart_cards                      = true
  #       redirect_webauthn                         = true
  #       usb_devices                               = "*"
  #     }
  #     display_settings = {
  #       desktop_size_id                 = 2
  #       desktop_height                  = 1080
  #       desktop_scale_factor            = 150
  #       desktop_width                   = 1920
  #       dynamic_resolution              = true
  #       maximize_to_current_displays    = true
  #       screen_mode                     = "FullScreen"
  #       selected_monitors               = "0,1"
  #       single_monitor_in_windowed_mode = false
  #       smart_sizing                    = true
  #       use_multimon                    = true
  #     }
  #   }
  # }

  # personal_example = {
  #   name                             = "db78da-avd-personal"
  #   host_pool_type                   = "Personal"
  #   personal_desktop_assignment_type = "Automatic"
  # }

  # scheduled_updates_example = {
  #   name        = "db78da-avd-scheduled"
  #   description = "Private-only AVD host pool"
  #   agent_update = {
  #     type                         = "Scheduled"
  #     use_session_host_local_time  = true
  #     maintenance_window_time_zone = "Pacific Standard Time"
  #     maintenance_windows = [
  #       {
  #         day_of_week = "Saturday"
  #         hour        = 2
  #       }
  #     ]
  #   }
  # }
}

scaling_plans = {
  pooled_daytime = {
    name          = "sp-e833c2-avd-pooled"
    exclusion_tag = "excludeFromScaling"
    host_pool_references = [
      {
        host_pool_key = "pooled_primary"
        enabled       = true
      }
    ]
    schedules = [
      {
        name                           = "weekday"
        daysOfWeek                     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        rampUpStartTime                = { hour = 6, minute = 0 }
        rampUpLoadBalancingAlgorithm   = "BreadthFirst"
        rampUpMinimumHostsPct          = 20
        rampUpCapacityThresholdPct     = 70
        peakStartTime                  = { hour = 8, minute = 0 }
        peakLoadBalancingAlgorithm     = "BreadthFirst"
        rampDownStartTime              = { hour = 17, minute = 0 }
        rampDownLoadBalancingAlgorithm = "DepthFirst"
        rampDownMinimumHostsPct        = 10
        rampDownCapacityThresholdPct   = 20
        rampDownForceLogoffUsers       = false
        rampDownWaitTimeMinutes        = 30
        rampDownNotificationMessage    = "Sign out soon to allow planned scale-down."
        rampDownStopHostsWhen          = "ZeroSessions"
        offPeakStartTime               = { hour = 20, minute = 0 }
        offPeakLoadBalancingAlgorithm  = "DepthFirst"
      },
      {
        name                           = "weekend"
        daysOfWeek                     = ["Saturday", "Sunday"]
        rampUpStartTime                = { hour = 8, minute = 0 }
        rampUpLoadBalancingAlgorithm   = "BreadthFirst"
        rampUpMinimumHostsPct          = 10
        rampUpCapacityThresholdPct     = 50
        peakStartTime                  = { hour = 10, minute = 0 }
        peakLoadBalancingAlgorithm     = "BreadthFirst"
        rampDownStartTime              = { hour = 15, minute = 0 }
        rampDownLoadBalancingAlgorithm = "DepthFirst"
        rampDownMinimumHostsPct        = 0
        rampDownCapacityThresholdPct   = 20
        rampDownForceLogoffUsers       = false
        rampDownWaitTimeMinutes        = 15
        rampDownNotificationMessage    = "Weekend scale-down is about to begin."
        rampDownStopHostsWhen          = "ZeroActiveSessions"
        offPeakStartTime               = { hour = 18, minute = 0 }
        offPeakLoadBalancingAlgorithm  = "DepthFirst"
      }
    ]
  }
}

network_security_groups = {
  avd_private_endpoints = {
    name = "nsg-avd-private-endpoints"
    security_rules = {
      allow_https_outbound = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      }
    }
  }

  avd_session_hosts = {
    name = "nsg-avd-session-hosts"
    security_rules = {
      # AVD session hosts require outbound HTTPS to Entra ID, AVD control plane,
      # Azure Monitor, and Storage. KMS activation requires TCP 1688.
      allow_entra_outbound = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureActiveDirectory"
      }
      allow_avd_service_outbound = {
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "WindowsVirtualDesktop"
      }
      allow_monitor_outbound = {
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureMonitor"
      }
      allow_storage_outbound = {
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "Storage"
      }
      allow_internet_https_outbound = {
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
      allow_kms_activation_outbound = {
        priority                   = 150
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1688"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
    }
  }
}

subnets = {
  avd_private_endpoints = {
    name                       = "snet-avd-private-endpoints"
    address_prefixes           = ["10.41.9.32/27"]
    network_security_group_key = "avd_private_endpoints"
  }

  avd_session_hosts = {
    name                       = "snet-avd-session-hosts"
    address_prefixes           = ["10.41.9.64/26"]
    network_security_group_key = "avd_session_hosts"
  }
}

### Supporting resources
log_analytics_workspaces = {
  avd = {
    name              = "law-e833c2-avd"
    retention_in_days = 90
  }
}

key_vaults = {
  avd = {
    name                        = "kv-e833c2-avd"
    create_local_admin_secrets  = false
    private_endpoint_subnet_key = "avd_private_endpoints"
  }
}

### Set create_local_admin_secrets = true only when Terraform runs from approved private connectivity.

### Existing networking – use when subnets/NSGs are pre-provisioned outside this module.
### Remove the corresponding entries from subnets / network_security_groups and add them here.
# existing_subnet_ids = {
#   avd_private_endpoints = "/subscriptions/.../subnets/snet-avd-private-endpoints"
# }
# existing_network_security_group_ids = {
#   avd_private_endpoints = "/subscriptions/.../networkSecurityGroups/nsg-avd-private-endpoints"
# }

workspaces = {
  primary = {
    name = "ws-e833c2-avd"
    private_endpoints = [
      {
        subnet_key        = "avd_private_endpoints"
        subresource_names = ["feed"]
      }
    ]
  }

  # global_feed_discovery_example = {
  #   name = "ws-e833c2-avd-global"
  #   private_endpoints = [
  #     {
  #       subnet_key        = "avd_private_endpoints"
  #       subresource_names = ["global"]
  #     }
  #   ]
  # }
}

application_groups = {
  desktop = {
    name          = "dag-e833c2-avd-desktop"
    type          = "Desktop"
    host_pool_key = "pooled_primary"
    workspace_key = "primary"
  }

  # remoteapp_with_assignments_example = {
  #   name          = "rag-e833c2-avd-apps"
  #   type          = "RailApplications"
  #   host_pool_key = "pooled_primary"
  #   workspace_key = "primary"
  #   assignments = {
  #     finance_users = {
  #       principal_id         = "00000000-0000-0000-0000-000000000000"
  #       principal_type       = "Group"
  #       role_definition_name = "Desktop Virtualization User"
  #     }
  #   }
  # }
}

### Session host example:
### This module now supports Azure VM-based session hosts for standard-management host pools.
### Keep the example commented until you have a dedicated subnet with outbound access to Microsoft Entra and AVD service endpoints.
session_hosts = {
  pooled_primary = {
    host_pool_key        = "pooled_primary"
    subnet_key           = "avd_session_hosts"
    instance_count       = 1
    vm_name_prefix       = "vm-e833c2-avdsh"
    computer_name_prefix = "avdsh"
    size                 = "Standard_D4ds_v4"
    # tags = { excludeFromScaling = "true" } # Optional: align with scaling_plans[*].exclusion_tag.
    vm_role_assignments = {
      avd_admins = {
        principal_id         = "26c9d2b5-dc78-460f-9b5c-4ae442ab5697" # PIM_DO_PuC_Dev_Infra_R_RE
        principal_type       = "Group"
        role_definition_name = "Virtual Machine Administrator Login"
      }
    }
  }
}

# session_host_customization_example = {
#   host_pool_key        = "pooled_primary"
#   subnet_key           = "avd_session_hosts"
#   instance_count       = 3
#   vm_name_prefix       = "vm-e833c2-avdsh"
#   computer_name_prefix = "avdsh"
#   size                 = "Standard_D8ds_v5"
#
#   ### OS disk
#   os_disk_storage_account_type = "Premium_LRS"  # StandardSSD_LRS (default) | Standard_LRS | Premium_LRS | UltraSSD_LRS
#   os_disk_size_gb              = 256             # Override image default (usually 128 GB). Leave null to keep image default.
#   # diff_disk_settings = {                       # Ephemeral OS disk for lowest latency stateless VMs.
#   #   option    = "CacheDisk"                    # CacheDisk or NvmeDisk (requires NVMe-capable SKU)
#   #   placement = "CacheDisk"                    # CacheDisk or ResourceDisk
#   # }
#
#   ### Networking
#   accelerated_networking_enabled = true          # Requires a VM size that supports AN (most v4/v5 D-series do).
#
#   ### Availability
#   availability_zone = 1                          # Pin to zone 1, 2, or 3 for zone-redundant deployments.
#
#   ### Image: use source_image_reference for Marketplace images or source_image_id for Azure Compute Gallery/custom images.
#   source_image_reference = {
#     publisher = "MicrosoftWindowsDesktop"
#     offer     = "office-365"
#     sku       = "win11-24h2-avd-m365"
#     version   = "latest"
#   }
#   # source_image_id = "/subscriptions/.../galleries/.../images/.../versions/latest"
#
#   ### Patching
#   patch_mode               = "AutomaticByOS"    # AutomaticByOS | AutomaticByPlatform | Manual
#   enable_automatic_updates = true
#
#   ### Diagnostics
#   enable_boot_diagnostics              = true    # Managed boot diagnostics (default). Set to false to disable.
#   # boot_diagnostics_storage_account_uri = "https://<account>.blob.core.windows.net/"  # Override to use a specific account.
#
#   ### Extensions
#   extensions_time_budget = "PT2H"               # ISO 8601. Increase if large images or slow storage cause extension timeouts.
#
#   ### Admin credentials
#   admin_username = "avdadmin"
#   # admin_password = ""                          # Leave null (default) to generate a strong random password stored in Terraform state.
#
#   vm_role_assignments = {
#     avd_users = {
#       principal_id         = "00000000-0000-0000-0000-000000000000"
#       principal_type       = "Group"
#       role_definition_name = "Virtual Machine User Login"
#     }
#     avd_admins = {
#       principal_id         = "26c9d2b5-dc78-460f-9b5c-4ae442ab5697" # PIM_DO_PuC_Dev_Infra_R_RE
#       principal_type       = "Group"
#       role_definition_name = "Virtual Machine Administrator Login"
#     }
#   }
#   tags = { excludeFromScaling = "true" }
# }

### Registration token rotation:
### Host pools ignore registrationInfo changes after creation to avoid token churn on every apply.
### To force a new token for a single host pool, run:
### terraform apply -replace='module.host_pools["pooled_primary"].azapi_resource.host_pool'
