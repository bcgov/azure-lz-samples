resource "azurerm_dev_center" "managed_devops_pool" {
  name                = var.dev_center_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  tags = var.tags
}

resource "azurerm_dev_center_project" "managed_devops_pool" {
  dev_center_id = azurerm_dev_center.managed_devops_pool.id

  name                = var.dev_center_project_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  tags = var.tags
}
