terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Microsoft.DesktopVirtualization/scalingPlans@2024-04-03
# Scaling plans are linked to host pools via the hostPoolReferences list.
#
# NOTE: The host pool's system-assigned managed identity must have the
#       "Desktop Virtualization Power On Off Contributor" role on the resource group
#       containing the session host VMs before autoscale can power VMs on/off.

resource "azapi_resource" "scaling_plan" {
  for_each             = var.scaling_plans
  type                 = "Microsoft.DesktopVirtualization/scalingPlans@2024-04-03"
  name                 = each.value.name
  parent_id            = var.resource_group_id
  location             = var.location
  tags                 = var.tags
  ignore_null_property = true

  body = {
    properties = {
      hostPoolType = each.value.host_pool_type
      friendlyName = each.value.friendly_name
      description  = each.value.description
      exclusionTag = each.value.exclusion_tag
      timeZone     = each.value.time_zone
      hostPoolReferences = [
        for ref in each.value.host_pool_references : {
          hostPoolArmPath    = ref.host_pool_id
          scalingPlanEnabled = ref.enabled
        }
      ]
      schedules = each.value.schedules
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azapi_resource" "diagnostics" {
  for_each  = var.enable_diagnostics ? var.scaling_plans : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${each.value.name}"
  parent_id = azapi_resource.scaling_plan[each.key].id

  body = {
    properties = {
      workspaceId = var.log_analytics_workspace_id
      logs = [
        {
          categoryGroup = each.value.diagnostic_log_category_group
          enabled       = true
          retentionPolicy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  }
}
