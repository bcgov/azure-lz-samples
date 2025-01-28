## Terraform register Azure Resource Providers
resource "azurerm_resource_provider_registration" "cloudshell_providers" {
  for_each = toset(var.resource_providers)
  name = each.key
}
