terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_string" "random" {
  length      = 6
  lower       = true
  upper       = false
  special     = false
  numeric     = true
  min_numeric = 2
}

resource "azapi_resource" "host_pool" {
  type      = "Microsoft.DesktopVirtualization/hostPools@2025-09-01-preview"
  name      = local.host_pool_name
  parent_id = var.resource_group_id
  location  = var.location

  identity {
    type = "SystemAssigned"
  }

  ignore_null_property = true
  tags                 = var.tags

  body = {
    properties = local.host_pool_properties
  }

  response_export_values = [
    "properties.registrationInfo",
    "properties.hostPoolType",
    "properties.publicNetworkAccess",
  ]

  lifecycle {
    ignore_changes = [
      body.properties.registrationInfo,
      tags,
    ]
  }
}

resource "azapi_resource" "host_pool_diagnostics" {
  for_each  = var.enable_diagnostics ? { enabled = var.log_analytics_workspace_id } : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${local.host_pool_name}"
  parent_id = azapi_resource.host_pool.id

  body = {
    properties = {
      workspaceId = each.value
      logs = [
        {
          categoryGroup = "allLogs"
          enabled       = true
        }
      ]
    }
  }
}
