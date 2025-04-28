resource "azapi_resource" "symbolicname" {
  type = "GitHub.Network/networkSettings@2024-04-02"
  name = "string"
  location = var.location
  tags = var.tags

  body = {
    properties = {
      businessId = var.github_organization_id
      subnetId = azapi_resource.github_hosted_runners_subnet.id
    }
  }
}
