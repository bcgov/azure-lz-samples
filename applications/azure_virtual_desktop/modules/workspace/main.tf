terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  friendly_name                 = var.friendly_name
  description                   = var.description
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azapi_resource" "diagnostics" {
  for_each  = var.enable_diagnostics ? { enabled = var.log_analytics_workspace_id } : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${var.name}"
  parent_id = azurerm_virtual_desktop_workspace.this.id

  body = {
    properties = {
      workspaceId = each.value
      logs = [
        {
          categoryGroup = var.diagnostic_log_category_group
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

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = "pe-${var.name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.name}-${each.key}"
    private_connection_resource_id = azurerm_virtual_desktop_workspace.this.id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}
