locals {
  container_registry_dns_zone_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s",
    var.environment == "live" ? "3c61ddb8-a5e7-49db-96d3-d32dd57ba7b3" : "09bd024b-fbda-417d-b8db-694680c2b44e",
    var.environment == "live" ? "bcgov-managed-lz-live-dns" : "bcgov-managed-lz-forge-dns",
    "privatelink.azurecr.io"
  )

  virtual_network_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s",
    data.azurerm_subscription.current.subscription_id, var.virtual_network_resource_group, var.virtual_network_name
  )

  container_app_subnet_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
    data.azurerm_subscription.current.subscription_id, var.virtual_network_resource_group, var.virtual_network_name, var.container_app_subnet_name
  )

  container_instance_subnet_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
    data.azurerm_subscription.current.subscription_id, var.virtual_network_resource_group, var.virtual_network_name, var.container_instance_subnet_name
  )

  private_endpoint_subnet_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
    data.azurerm_subscription.current.subscription_id, var.virtual_network_resource_group, var.virtual_network_name, var.private_endpoint_subnet_name
  )
}

locals {
  # NOTE: This can only be a Resource Group name (ie. to create a new Resource Group).
  # The Azure Container App Environment does not support the use of an existing Resource Group, it needs to create its own, and will use this name.
  container_app_infrastructure_resource_group_name = "${var.resource_group_name}_container_app_infra"
}
