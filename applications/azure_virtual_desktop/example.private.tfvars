resource_group_name                 = "e833c2-dev-avd-private"
location                            = "canadacentral"
virtual_network_name                = "e833c2-dev-vwan-spoke"
virtual_network_resource_group_name = "e833c2-dev-networking"

# Option 2: Private-only user access
# - Workspace feed is private endpoint only.
# - Host pool is private endpoint only with public access disabled.
# - Users must have private network reachability + private DNS.

host_pools = {
  pooled_private = {
    name                   = "e833c2-avd-hp-private"
    friendly_name          = "e833c2 Private Host Pool"
    validation_environment = false
    public_network_access  = "Disabled"
    private_endpoints = [
      {
        subnet_key        = "avd_private_endpoints"
        subresource_names = ["connection"]
      }
    ]
  }
}

scaling_plans = {
  pooled_private_daytime = {
    name          = "sp-e833c2-avd-private"
    friendly_name = "e833c2 Private Scaling"
    exclusion_tag = "excludeFromScaling"
    host_pool_references = [
      {
        host_pool_key = "pooled_private"
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

log_analytics_workspaces = {
  avd = {
    name              = "law-e833c2-avd-private"
    retention_in_days = 90
  }
}

# Set to false when diagnostics are created by Azure Policy assignments
# in the target subscription to prevent diagnostic-setting create conflicts.
manage_diagnostic_settings = false

# Key Vault (optional)
# -----------------------------------------------------------------------
# Key Vault is NOT required for a functional AVD deployment.
# Its sole purpose in this module is to store the session host local admin
# credentials (AVD-Local-Admin-Username / AVD-Local-Admin-Password) as
# Key Vault secrets when create_local_admin_secrets = true.
#
# DEPLOYMENT CONSTRAINT — private runner required:
#   The vault is always created with public_network_access_enabled = false.
#   When create_local_admin_secrets = true, Terraform must write secrets to
#   the vault over its private endpoint. This requires the pipeline or CLI
#   session to run from inside the private network (e.g. a self-hosted
#   GitHub/ADO runner or Azure Bastion jump host that has DNS resolution
#   for privatelink.vaultcore.azure.net and line-of-sight to the
#   avd_private_endpoints subnet). Running from a public GitHub-hosted
#   runner will fail at secret creation.
#
# In this private-only deployment ALL Key Vault operations (read and write)
# require private network reachability — there is no fallback public path.
#
# When create_local_admin_secrets = false (default):
#   The vault is provisioned but no secrets are written. The local admin
#   password is still auto-generated and stored only in Terraform state.
#   In this case the vault provides no active value and can be safely
#   omitted by removing this block entirely (key_vaults = {}).
#
# End-user authentication uses Entra ID SSO — local admin credentials are
# for emergency VM console access only.
key_vaults = {
  avd = {
    name                        = "kv-e833c2-avd-private"
    create_local_admin_secrets  = false # set true only from a private runner
    private_endpoint_subnet_key = "avd_private_endpoints"
  }
}

workspaces = {
  private = {
    name                          = "ws-e833c2-avd-private"
    friendly_name                 = "e833c2 Private AVD Workspace"
    public_network_access_enabled = false
    private_endpoints = [
      {
        subnet_key        = "avd_private_endpoints"
        subresource_names = ["feed"]
      }
    ]
  }
}

application_groups = {
  desktop_private = {
    name          = "dag-e833c2-avd-desktop-private"
    friendly_name = "e833c2 Private Desktop Group"
    type          = "Desktop"
    host_pool_key = "pooled_private"
    workspace_key = "private"

    # ---------------------------------------------------------------------------
    # assignments — optional. Grant principals the Desktop Virtualization User
    # role on this application group, which allows them to see and launch the
    # desktop or app in the AVD client. Omit the block entirely to skip.
    #
    # Each map key is a stable Terraform identity (any unique string).
    # principal_type: "User", "Group", or "ServicePrincipal" (optional but
    #   recommended — speeds up role assignment creation).
    # role_definition_name: defaults to "Desktop Virtualization User" if omitted.
    # ---------------------------------------------------------------------------
    assignments = {
      avd_users = {
        principal_id         = "26c9d2b5-dc78-460f-9b5c-4ae442ab5697" # PIM_DO_PuC_Dev_Infra_R_RE
        principal_type       = "Group"
        role_definition_name = "Desktop Virtualization User" # default
      }
    }
  }
}

session_hosts = {
  pooled_private = {
    host_pool_key        = "pooled_private"
    subnet_key           = "avd_session_hosts"
    instance_count       = 1
    vm_name_prefix       = "vm-e833c2-avdprvsh"
    computer_name_prefix = "avdprvsh"
    size                 = "Standard_D4ds_v4"
    vm_role_assignments = {
      avd_admins = {
        principal_id         = "26c9d2b5-dc78-460f-9b5c-4ae442ab5697"
        principal_type       = "Group"
        role_definition_name = "Virtual Machine Administrator Login"
      }
    }
  }
}

fslogix_storage = {
  name                        = "stfslogix833c2prv"
  private_endpoint_subnet_key = "avd_private_endpoints"
  account_tier                = "Premium"
  account_replication_type    = "ZRS"
  share_name                  = "profiles"
  share_quota_gb              = 1024
}
