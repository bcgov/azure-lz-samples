locals {
  devopsinfrastructure_service_principal_id = "dd71ac9e-f14e-435e-b855-6c6fd377d9c1" # Object ID of 'DevOpsInfrastructure'
  networkContributorRoleDefinitionId        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"

  role_assignments = {
    "managed_devops_pool" = {
      role_definition_id_or_name       = local.networkContributorRoleDefinitionId
      principal_id                     = local.devopsinfrastructure_service_principal_id
      skip_service_principal_aad_check = true
      principal_type                   = "ServicePrincipal"
    }
  }

  virtual_network_location = data.azurerm_virtual_network.vnet.location

  managed_devops_pool_subnet_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
    data.azurerm_subscription.current.subscription_id, var.virtual_network_resource_group, var.virtual_network_name, var.managed_devops_pool_subnet_name
  )
}
