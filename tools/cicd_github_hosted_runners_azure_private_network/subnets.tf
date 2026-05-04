resource "azapi_resource" "github_hosted_runners_subnet" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  name      = var.github_hosted_runners_subnet_name
  parent_id = data.azurerm_virtual_network.vnet.id
  locks = [
    data.azurerm_virtual_network.vnet.id
  ]

  body = {
    properties = {
      addressPrefix         = var.github_hosted_runners_subnet_address_prefix
      defaultOutboundAccess = false
      delegations = [
        {
          name = "GitHubHostedRunners"
          properties = {
            serviceName = "GitHub.Network/networkSettings"
          }
        }
      ]
      networkSecurityGroup = {
        id = azurerm_network_security_group.github_hosted_runners_nsg.id
      }
    }
  }
  response_export_values = ["*"]
}
