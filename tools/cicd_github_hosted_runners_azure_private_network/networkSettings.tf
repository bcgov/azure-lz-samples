resource "azapi_resource" "github_hosted_runners_network_settings" {
  type      = "GitHub.Network/networkSettings@2024-04-02"
  name      = var.network_settings_name
  parent_id = data.azurerm_resource_group.vnet_rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      businessId = var.github_organization_id # NOTE: Cannot be updated after creation (The operation is not allowed. Attempt to modify immutable property 'BusinessId')
      subnetId   = azapi_resource.github_hosted_runners_subnet.id
    }
  }

  lifecycle {
    ignore_changes = [
      tags["GitHubId"]
    ]
  }
}
