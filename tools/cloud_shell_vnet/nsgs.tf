resource "azurerm_network_security_group" "container_nsg" {
  name                = "private-cloudshell"
  location            = local.location
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

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_security_group" "relay_nsg" {
  name                = "private-cloudshell-relay"
  location            = local.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_security_group" "storage_nsg" {
  name                = "private-cloudshell-storage"
  location            = local.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
