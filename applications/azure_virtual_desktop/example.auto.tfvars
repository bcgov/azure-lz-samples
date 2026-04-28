resource_group_name                 = "e833c2-dev-avd"
location                            = "canadacentral"
virtual_network_name                = "e833c2-dev-vwan-spoke"
virtual_network_resource_group_name = "e833c2-dev-networking"

host_pools = {
  pooled_primary = {
    name = "e833c2-avd-hostpool"
  }

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
    name = "sp-e833c2-avd-pooled"
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
}

subnets = {
  avd_private_endpoints = {
    name                       = "snet-avd-private-endpoints"
    address_prefixes           = ["10.41.9.32/27"]
    network_security_group_key = "avd_private_endpoints"
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
  }
}

application_groups = {
  desktop = {
    name          = "dag-e833c2-avd-desktop"
    type          = "Desktop"
    host_pool_key = "pooled_primary"
    workspace_key = "primary"
  }
}

### Registration token rotation:
### Host pools ignore registrationInfo changes after creation to avoid token churn on every apply.
### To force a new token for a single host pool, run:
### terraform apply -replace='module.host_pools["pooled_primary"].azapi_resource.host_pool'
