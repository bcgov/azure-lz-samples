resource "azurerm_private_endpoint" "example" {
  depends_on = [
    azapi_update_resource.relay_subnet,
    azurerm_relay_namespace.cloudshell
  ]

  name                = var.privateEndpointName
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  subnet_id           = azapi_update_resource.relay_subnet.id

  private_service_connection {
    name                           = var.privateEndpointName
    private_connection_resource_id = azurerm_relay_namespace.cloudshell.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
}
