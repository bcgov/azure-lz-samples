data "azurerm_virtual_network" "existing" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "azure_virtual_desktop" {
  client_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}
