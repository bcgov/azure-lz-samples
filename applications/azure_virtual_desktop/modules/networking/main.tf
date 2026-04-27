terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }

    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.network_security_rules

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  description                  = each.value.description
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this[each.value.network_security_group_key].name
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
}

resource "azapi_resource" "subnet" {
  for_each = var.subnets

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name      = each.value.name
  parent_id = var.virtual_network_id
  locks     = [var.virtual_network_id]

  ignore_null_property = true

  body = {
    properties = merge(
      {
        addressPrefixes                   = each.value.address_prefixes
        privateEndpointNetworkPolicies    = each.value.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"
        privateLinkServiceNetworkPolicies = each.value.private_link_service_network_policies_enabled ? "Enabled" : "Disabled"
      },
      each.value.network_security_group_key == null ? {} : {
        networkSecurityGroup = {
          id = azurerm_network_security_group.this[each.value.network_security_group_key].id
        }
      },
      length(each.value.service_endpoints) == 0 ? {} : {
        serviceEndpoints = [
          for service in each.value.service_endpoints : {
            service = service
          }
        ]
      },
      each.value.delegation_service_name == null ? {} : {
        delegations = [
          {
            name = coalesce(each.value.delegation_name, "${each.value.name}-delegation")
            properties = {
              serviceName = each.value.delegation_service_name
            }
          }
        ]
      }
    )
  }
}
