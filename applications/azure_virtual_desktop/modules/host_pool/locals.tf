locals {
  host_pool_name = "${var.host_pool_name}-${random_string.random.result}"

  registration_token_expiry = timeadd(timestamp(), "${var.registration_token_expiry_hours}h")

  agent_update = merge(
    {
      type                    = var.agent_update_type
      useSessionHostLocalTime = var.agent_update_use_session_host_local_time
    },
    var.agent_update_type == "Scheduled" ? {
      maintenanceWindows = [
        for window in var.agent_update_maintenance_windows : {
          dayOfWeek = window.day_of_week
          hour      = window.hour
        }
      ]
    } : tomap({}),
    var.agent_update_type == "Scheduled" ? {
      maintenanceWindowTimeZone = coalesce(var.agent_update_maintenance_window_time_zone, "UTC")
    } : tomap({})
  )

  host_pool_properties = merge(
    {
      allowRDPShortPathWithPrivateLink = var.allow_rdp_shortpath_with_private_link
      deploymentScope                  = var.deployment_scope
      directUDP                        = var.direct_udp
      hostPoolType                     = var.host_pool_type
      loadBalancerType                 = var.load_balancer_type
      managedPrivateUDP                = var.managed_private_udp
      managementType                   = var.management_type
      preferredAppGroupType            = var.preferred_app_group_type
      publicNetworkAccess              = var.public_network_access
      publicUDP                        = var.public_udp
      relayUDP                         = var.relay_udp
      startVMOnConnect                 = var.start_vm_on_connect
      validationEnvironment            = var.validation_environment
    },
    var.agent_update_type == "Scheduled" ? { agentUpdate = local.agent_update } : {},
    var.friendly_name == null ? {} : { friendlyName = var.friendly_name },
    var.description == null ? {} : { description = var.description },
    var.custom_rdp_properties == null ? {} : { customRdpProperty = var.custom_rdp_properties },
    var.max_session_limit == null ? {} : { maxSessionLimit = var.max_session_limit },
    var.personal_desktop_assignment_type == null ? {} : { personalDesktopAssignmentType = var.personal_desktop_assignment_type },
    var.ring == null ? {} : { ring = var.ring },
    var.vm_template == null ? {} : { vmTemplate = var.vm_template },
    var.registration_token_operation == "None" ? {} : {
      registrationInfo = {
        expirationTime             = local.registration_token_expiry
        registrationTokenOperation = var.registration_token_operation
      }
    }
  )
}
