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
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  friendly_name       = var.friendly_name
  description         = var.description
  tags                = var.tags

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
        },
        {
          categoryGroup = var.diagnostic_log_category_group == "allLogs" ? "audit" : "allLogs"
          enabled       = false
          retentionPolicy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  }
}
