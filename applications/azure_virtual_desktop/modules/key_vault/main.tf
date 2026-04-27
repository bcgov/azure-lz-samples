terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  rbac_authorization_enabled    = var.enable_rbac_authorization
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = false
  tags                          = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "deployer_secrets_officer" {
  for_each             = var.create_local_admin_secrets ? { enabled = true } : {}
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.deployer_object_id
}

# Random password for the AVD local admin account.
# lifecycle ignore_changes ensures a re-plan does not rotate the password.
resource "random_password" "avd_local_admin" {
  for_each         = var.create_local_admin_secrets ? { enabled = true } : {}
  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# NOTE: The identity running Terraform must hold the Key Vault Secrets Officer
# role on this vault (or at subscription/RG scope) to write secrets.
# Deployment must run from within the private network (self-hosted runner)
# because public_network_access_enabled = false.
resource "azurerm_key_vault_secret" "avd_local_admin_username" {
  for_each     = var.create_local_admin_secrets ? { enabled = true } : {}
  name         = "AVD-Local-Admin-Username"
  value        = var.avd_local_admin_username
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.deployer_secrets_officer["enabled"],
  ]

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "avd_local_admin_password" {
  for_each     = var.create_local_admin_secrets ? { enabled = true } : {}
  name         = "AVD-Local-Admin-Password"
  value        = random_password.avd_local_admin["enabled"].result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.deployer_secrets_officer["enabled"],
  ]

  lifecycle {
    ignore_changes = [value]
  }
}

# Private endpoint – no dns_zone_group block (DNS record created by DINE policy).
resource "azurerm_private_endpoint" "this" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  lifecycle {
    # Private DNS zone group is injected by policy (DINE) and should not cause drift in this module.
    ignore_changes = [tags, private_dns_zone_group]
  }
}

resource "azapi_resource" "diagnostics" {
  for_each  = var.enable_diagnostics ? { enabled = var.log_analytics_workspace_id } : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${var.name}"
  parent_id = azurerm_key_vault.this.id

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
