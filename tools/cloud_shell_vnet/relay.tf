resource "azurerm_relay_namespace" "cloudshell" {
  name                = var.relayNamespaceName
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  sku_name = "Standard"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
