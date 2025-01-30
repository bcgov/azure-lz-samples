resource "azurerm_storage_account" "cloudshell" {
  name                = lower(var.storageAccountName)
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    virtual_network_subnet_ids = [
      azapi_resource.container_subnet.id,
      azapi_resource.storage_subnet.id
    ]
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_share" "cloudshell_share" {
  name               = var.fileShareName
  storage_account_id = azurerm_storage_account.cloudshell.id
  quota              = 6
}
