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

# ---------------------------------------------------------------------------
# Storage account
# Premium FileStorage is required for Azure Files shares with SMB and
# identity-based (Entra Kerberos) authentication at sub-millisecond latency.
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_tier == "Premium" ? "FileStorage" : "StorageV2"
  tags                     = var.tags

  # SMB security hardening
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false # Entra identity-based auth only

  lifecycle {
    ignore_changes = [tags]
  }
}

# azurerm 4.x removed the azure_files_identity_based_authentication block from
# azurerm_storage_account.  Use azapi_update_resource to configure Entra Kerberos
# (AADKERB) authentication, which is required for Entra-joined AVD session hosts.
resource "azapi_update_resource" "entra_kerberos" {
  type        = "Microsoft.Storage/storageAccounts@2024-01-01"
  resource_id = azurerm_storage_account.this.id

  body = {
    properties = {
      azureFilesIdentityBasedAuthentication = {
        directoryServiceOptions = "AADKERB"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Azure Files share for FSLogix profile containers
# ---------------------------------------------------------------------------
resource "azurerm_storage_share" "profiles" {
  name               = var.share_name
  storage_account_id = azurerm_storage_account.this.id
  quota              = var.share_quota_gb

  # ACL is managed via RBAC; no storage-level ACE required.
  enabled_protocol = "SMB"
}

# ---------------------------------------------------------------------------
# Private endpoint — DNS A record created by DINE policy (no dns_zone_group).
# ---------------------------------------------------------------------------
resource "azurerm_private_endpoint" "this" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}

# ---------------------------------------------------------------------------
# RBAC: Storage File Data SMB Share Contributor
# Assigned to session host VM identities and optional additional principals.
# This role allows Kerberos-authenticated SMB access to the file share.
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "smb_contributor" {
  for_each = toset(var.smb_contributor_principal_ids)

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = each.value
}

# ---------------------------------------------------------------------------
# Diagnostics — storage accounts expose two separate diagnostic targets:
#   1. The storage account resource itself — supports metrics only (no log
#      categories). Transaction metric captures account-level throughput.
#   2. The file service endpoint (fileServices/default) — supports both
#      metrics and log categories (StorageRead/StorageWrite/StorageDelete
#      via allLogs). This is where SMB access events for FSLogix profile
#      containers are emitted and must be enabled for access auditing.
# ---------------------------------------------------------------------------
resource "azapi_resource" "diagnostics" {
  for_each  = var.enable_diagnostics ? { enabled = var.log_analytics_workspace_id } : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${var.name}"
  parent_id = azurerm_storage_account.this.id

  body = {
    properties = {
      workspaceId = each.value
      metrics = [
        {
          category = "Transaction"
          enabled  = true
          retentionPolicy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  }
}

# File service level diagnostic settings. Log categories (StorageRead,
# StorageWrite, StorageDelete) are only available on the file service endpoint,
# not on the storage account resource itself. This captures SMB operations
# against the FSLogix profiles share for access auditing.
resource "azapi_resource" "diagnostics_file_service" {
  for_each  = var.enable_diagnostics ? { enabled = var.log_analytics_workspace_id } : {}
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = "diag-${var.name}-filesvc"
  parent_id = "${azurerm_storage_account.this.id}/fileServices/default"

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
      metrics = [
        {
          category = "Transaction"
          enabled  = true
          retentionPolicy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  }
}
