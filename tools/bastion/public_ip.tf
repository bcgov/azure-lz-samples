resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${var.bastion_host_name}-${random_string.random.result}-publicip"
  resource_group_name = azurerm_resource_group.bastion_rg.name
  location            = azurerm_resource_group.bastion_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
