resource "azurerm_resource_group" "bastion_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "random" {
  length      = 6
  lower       = true
  upper       = false
  special     = false
  numeric     = true
  min_numeric = 2
}

module "azure_bastion" {
  source           = "Azure/avm-res-network-bastionhost/azurerm"
  enable_telemetry = true

  name                = "${var.bastion_host_name}-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.bastion_rg.name
  location            = azurerm_resource_group.bastion_rg.location

  copy_paste_enabled        = var.copy_paste_enabled
  file_copy_enabled         = var.file_copy_enabled
  sku                       = var.sku
  ip_connect_enabled        = var.ip_connect_enabled
  kerberos_enabled          = var.kerberos_enabled
  scale_units               = var.scale_units
  shareable_link_enabled    = var.shareable_link_enabled
  tunneling_enabled         = var.tunneling_enabled
  session_recording_enabled = var.session_recording_enabled

  ip_configuration = {
    name                 = "${var.bastion_host_name}-ipconfig"
    subnet_id            = azapi_resource.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }

  tags = var.tags
}
