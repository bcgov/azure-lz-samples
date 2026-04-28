terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }

    azurerm = {
      source = "hashicorp/azurerm"
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

resource "azurerm_private_endpoint" "this" {
  for_each = { for index, definition in var.private_endpoints : tostring(index) => definition }

  name                = "pe-${local.host_pool_name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${local.host_pool_name}-${each.key}"
    private_connection_resource_id = azapi_resource.host_pool.id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}
