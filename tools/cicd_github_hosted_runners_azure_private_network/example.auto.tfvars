subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # This is the subscription ID where the resources will be created (ie. abc123-tools)

location            = "Canada Central"

existing_virtual_network_resource_group_name = "abc123-tools-networking" # Existing Virtual Network Resource Group Name (ie. abc123-tools-networking)
existing_virtual_network_name                = "abc123-tools-vwan-spoke" # Existing Virtual Network Name (ie. abc123-tools-vwan-spoke)

github_hosted_runners_subnet_name           = "ghr-aca"
github_hosted_runners_subnet_address_prefix = "10.41.4.64/27" # must be a minimum size of `/27`

tags = { # NOTE: Add this to avoid removing tags that have been inherited from the resource group (on subsequent runs)
  account_coding = "000000000000000000000000"
  billing_group  = "abc123"
  ministry_name  = "MINISTRY_NAME"
}
