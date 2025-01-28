resource "azurerm_role_assignment" "network_profile" {
  depends_on = [azurerm_network_profile.cloudshell]

  # NOTE: Grants Network Contributor to the Azure Container Instance Service on the Network Profile
  scope = azurerm_network_profile.cloudshell.id
  # role_definition_name = "Network Contributor"
  role_definition_id = local.networkRoleDefinitionId
  principal_id       = local.azureContainerInstanceOID
}

resource "azurerm_role_assignment" "relay_namespace" {
  depends_on = [azurerm_relay_namespace.cloudshell]

  # NOTE: Grants Contributor to the Azure Container Instance Service on the Relay Namespace
  scope = azurerm_relay_namespace.cloudshell.id
  # role_definition_name = "Contributor"
  role_definition_id = local.contributorRoleDefinitionId
  principal_id       = local.azureContainerInstanceOID
}
