resource "azurerm_network_security_group" "container_nsg" {
  name                = "private-cloudshell"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  security_rule {
    name                       = "DenyIntraSubnetTraffic"
    description                = "Deny traffic between container groups in the CloudShell subnet."
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.containerSubnetAddressPrefix
    destination_address_prefix = var.containerSubnetAddressPrefix
  }
}

resource "azurerm_network_security_group" "relay_nsg" {
  name                = "private-cloudshell-relay"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
}

resource "azurerm_network_security_group" "storage_nsg" {
  name                = "private-cloudshell-storage"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
}
