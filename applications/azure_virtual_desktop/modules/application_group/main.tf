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

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = var.type
  host_pool_id        = var.host_pool_id
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
  parent_id = azurerm_virtual_desktop_application_group.this.id

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

resource "azurerm_role_assignment" "assignment" {
  for_each = var.assignments

  scope                = azurerm_virtual_desktop_application_group.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  principal_type       = try(each.value.principal_type, null)
}
