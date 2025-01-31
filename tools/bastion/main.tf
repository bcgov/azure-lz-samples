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

  copy_paste_enabled = true
  file_copy_enabled  = false
  sku                = "Basic"

  ip_configuration = {
    name                 = "${var.bastion_host_name}-ipconfig"
    subnet_id            = azapi_resource.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }

  ip_connect_enabled        = false
  kerberos_enabled          = false
  scale_units               = 2
  shareable_link_enabled    = false
  tunneling_enabled         = false
  session_recording_enabled = false

  tags = var.tags
}
