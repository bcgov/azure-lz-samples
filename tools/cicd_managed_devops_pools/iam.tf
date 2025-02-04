resource "azurerm_role_assignment" "vnet_network_contributor" {
  # NOTE: Grants Network Contributor to the DevOpsInfrastructure service principal on the Virtual Network
  scope              = data.azurerm_virtual_network.vnet.id
  role_definition_id = local.networkContributorRoleDefinitionId
  principal_id       = local.devopsinfrastructure_service_principal_id
}
