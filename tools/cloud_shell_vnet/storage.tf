resource "azurerm_storage_account" "cloudshell" {
  name                = lower(var.storageAccountName)
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  location                 = data.azurerm_virtual_network.vnet.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool"

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    virtual_network_subnet_ids = [
      azapi_update_resource.container_subnet.id,
      azapi_update_resource.storage_subnet.id
    ]
  }
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
}

resource "azurerm_storage_share" "cloudshell_share" {
  name               = var.fileShareName
  storage_account_id = azurerm_storage_account.cloudshell.id
  quota              = 6
}
