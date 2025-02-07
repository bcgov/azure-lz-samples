locals {
  networkProfileName          = "aci-networkProfile"
  contributorRoleDefinitionId = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  networkRoleDefinitionId     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"

  # The Object ID for the Azure Container Instance Service
  azureContainerInstanceOID = "0b83814e-03a5-487e-a870-a0f21b340f53"

  location = data.azurerm_virtual_network.vnet.location
}
