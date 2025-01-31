resource "azapi_resource" "bastion_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = "AzureBastionSubnet"
  parent_id = data.azurerm_virtual_network.vnet.id
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix = var.bastionSubnetAddressPrefix
      networkSecurityGroup = {
        id = azurerm_network_security_group.bastion_nsg.id
      }
    }
  }
  response_export_values = ["*"]
}
