virtual_network_name           = "abc123-dev-vwan-spoke"
virtual_network_resource_group = "abc123-dev-networking"

resource_group_name        = "abc123-dev-bastion"
bastion_host_name          = "bastion" # NOTE: Will be appended with a random string
location                   = "canadacentral"
bastionSubnetAddressPrefix = "10.41.0.0/26"

sku                = "Basic"
copy_paste_enabled = true # Configuration: Copy and paste

### Standard / Premium features:
# file_copy_enabled = true # Configuration: File transfer using a native client
# ip_connect_enabled = true # Configuration: IP-based connection
# kerberos_enabled = true # Configuration: Kerberos authentication
# scale_units = 4 # Configuration: Instance count
# shareable_link_enabled = true # Configuration: Shareable Link
# tunneling_enabled = true # Configuration: Native client support
# session_recording_enabled = true # Configuration: Session recording (Preview)
