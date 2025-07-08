subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # This is the subscription ID where the resources will be created (ie. abc123-tools)

resource_group_name = "caf-ghr"
location            = "Canada Central"

postfix = "ghr"

version_control_system_type         = "github"
version_control_system_organization = "bcgov-c"                                 # The organization name in the version control system
version_control_system_repository   = "ecf-azure-startup-sample-app-serverless" # The repository name in the version control system
# export TF_VAR_github_personal_access_token=<your_github_personal_access_token>

existing_virtual_network_resource_group_name = "abc123-tools-networking" # Existing Virtual Network Resource Group Name (ie. abc123-tools-networking)
existing_virtual_network_name                = "abc123-tools-vwan-spoke" # Existing Virtual Network Name (ie. abc123-tools-vwan-spoke)

container_app_subnet_name           = "ghr-aca"
container_app_subnet_address_prefix = "10.41.4.64/27" # must be a minimum size of `/27`

container_instance_subnet_name           = "ghr-aci"
container_instance_subnet_address_prefix = "10.41.4.96/28" # must be a minimum size of `/28`

private_endpoint_subnet_name           = "private-endpoints"
private_endpoint_subnet_address_prefix = "10.41.4.112/28"

compute_types = ["azure_container_app"]

tags = { # NOTE: Add this to avoid removing tags that have been inherited from the resource group (on subsequent runs)
  account_coding = "000000000000000000000000"
  billing_group  = "abc123"
  ministry_name  = "MINISTRY_NAME"
}
