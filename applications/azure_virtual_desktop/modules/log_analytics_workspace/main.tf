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

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb >= 0 ? var.daily_quota_gb : null
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# The workspace sends its own audit/operational logs to itself.
resource "azapi_resource" "diagnostics" {
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${var.name}"
  parent_id = azurerm_log_analytics_workspace.this.id

  body = {
    properties = {
      workspaceId = azurerm_log_analytics_workspace.this.id
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
