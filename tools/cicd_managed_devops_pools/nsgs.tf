resource "azurerm_network_security_group" "managed_devops_pool_nsg" {
  name                = var.managed_devops_pool_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
