subscription_id = "d6d8a667-4d0d-4cc1-9245-0a7e2834caeb" # This is the subscription ID where the resources will be created (ie. abc123-tools)

location = "Canada Central"

existing_virtual_network_resource_group_name = "e833c2-tools-networking" # Existing Virtual Network Resource Group Name (ie. abc123-tools-networking)
existing_virtual_network_name                = "e833c2-tools-vwan-spoke" # Existing Virtual Network Name (ie. abc123-tools-vwan-spoke)

github_hosted_runners_subnet_name           = "github-hosted-runners" # Name of the subnet to be created (ie. github-hosted-runners)
github_hosted_runners_subnet_address_prefix = "10.41.4.64/28"
network_settings_name                       = "ghrs"
# export TF_VAR_github_organization_id=123456 # Provide the appropriate value during deployment

# NOTE: Adding tags are optional
tags = {
  account_coding = "000000000000000000000000"
  billing_group  = "e833c2"
  ministry_name  = "CITZ"
}
