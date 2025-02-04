resource "azapi_resource" "managed_devops_pool_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.managed_devops_pool_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix = var.managed_devops_pool_subnet_address_prefix
      delegations = [
        {
          name = "ManagedDevOpsPool"
          properties = {
            serviceName = "Microsoft.DevOpsInfrastructure/pools"
          }
        }
      ]
      networkSecurityGroup = {
        id = azurerm_network_security_group.managed_devops_pool_nsg.id
      }
    }
  }
  response_export_values = ["*"]
}
