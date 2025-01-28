resource "azapi_resource" "container_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.containerSubnetName
  parent_id = data.azurerm_virtual_network.vnet.id
  # Note: Discovered the `locks` attribute for AzAPI from the following GitHub Issue: https://github.com/Azure/terraform-provider-azapi/issues/503
  # A list of ARM resource IDs which are used to avoid create/modify/delete azapi resources at the same time.
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix = var.containerSubnetAddressPrefix
      delegations = [
        {
          name = "CloudShellDelegation"
          properties = {
            serviceName = "Microsoft.ContainerInstance/containerGroups"
          }
        }
      ]
      networkSecurityGroup = {
        id = azurerm_network_security_group.container_nsg.id
      }
      serviceEndpoints = [
        {
          locations = [
            data.azurerm_virtual_network.vnet.location
          ]
          service = "Microsoft.Storage"
        }
      ]
    }
  }
  response_export_values = ["*"]
}

resource "azapi_resource" "relay_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.relaySubnetName
  parent_id = data.azurerm_virtual_network.vnet.id
  # Note: Discovered the `locks` attribute for AzAPI from the following GitHub Issue: https://github.com/Azure/terraform-provider-azapi/issues/503
  # A list of ARM resource IDs which are used to avoid create/modify/delete azapi resources at the same time.
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix = var.relaySubnetAddressPrefix
      networkSecurityGroup = {
        id = azurerm_network_security_group.relay_nsg.id
      }
      privateEndpointNetworkPolicies    = "Disabled"
      privateLinkServiceNetworkPolicies = "Enabled"
    }
  }
  response_export_values = ["*"]
}

resource "azapi_resource" "storage_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.storageSubnetName
  parent_id = data.azurerm_virtual_network.vnet.id
  # Note: Discovered the `locks` attribute for AzAPI from the following GitHub Issue: https://github.com/Azure/terraform-provider-azapi/issues/503
  # A list of ARM resource IDs which are used to avoid create/modify/delete azapi resources at the same time.
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix = var.storageSubnetAddressPrefix
      networkSecurityGroup = {
        id = azurerm_network_security_group.storage_nsg.id
      }
      serviceEndpoints = [
        {
          locations = [
            data.azurerm_virtual_network.vnet.location
          ]
          service = "Microsoft.Storage"
        }
      ]
    }
  }
  response_export_values = ["*"]
}
