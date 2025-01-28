resource "azurerm_network_profile" "cloudshell" {
  depends_on = [azapi_update_resource.container_subnet]

  name                = "${local.networkProfileName}-${data.azurerm_virtual_network.vnet.location}"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  container_network_interface {
    name = "eth-${var.containerSubnetName}"

    ip_configuration {
      name      = "ipconfig-${var.containerSubnetName}"
      subnet_id = azapi_update_resource.container_subnet.id
    }
  }
}
