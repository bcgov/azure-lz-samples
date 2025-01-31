virtual_network_name           = "abc123-dev-vwan-spoke"
virtual_network_resource_group = "abc123-dev-networking"

resource_group_name        = "abc123-dev-bastion"
bastion_host_name          = "bastion" # NOTE: Will be appended with a random string
location                   = "canadacentral"
bastionSubnetAddressPrefix = "10.41.0.0/26"
