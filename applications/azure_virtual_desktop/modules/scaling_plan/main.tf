terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Microsoft.DesktopVirtualization/scalingPlans@2024-04-03
# Scaling plans are linked to host pools via the hostPoolReferences list.
# publicNetworkAccess is hardcoded to "Disabled" consistent with the host pool.
#
# NOTE: The host pool's system-assigned managed identity must have the
#       "Desktop Virtualization Power On Off Contributor" role on the resource group
#       containing the session host VMs before autoscale can power VMs on/off.

resource "azapi_resource" "scaling_plan" {
  for_each  = var.scaling_plans
  type      = "Microsoft.DesktopVirtualization/scalingPlans@2024-04-03"
  name      = each.value.name
  parent_id = var.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      hostPoolType        = each.value.host_pool_type
      publicNetworkAccess = "Disabled"
      friendlyName        = each.value.friendly_name
      description         = each.value.description
      timeZone            = each.value.time_zone
      hostPoolReferences = [
        for ref in each.value.host_pool_references : {
          hostPoolArmPath    = ref.host_pool_id
          scalingPlanEnabled = ref.enabled
        }
      ]
      schedules = each.value.schedules
    }
  }
}
