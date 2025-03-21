resource_group_name = "caf-ghr"
location            = "Canada Central"

postfix = "ghr"

version_control_system_type         = "github"
version_control_system_organization = "bcgov-c"   # The organization name in the version control system
version_control_system_repository   = "REPO_NAME" # The repository name in the version control system
# export TF_VAR_github_personal_access_token=<your_github_personal_access_token>

virtual_network_resource_group = "abc123-tools-networking"
virtual_network_name           = "abc123-tools-vwan-spoke"

container_app_subnet_name           = "ghr-aca"
container_app_subnet_address_prefix = "1.2.3.4/27" # must be a minimum size of `/27`

container_instance_subnet_name           = "ghr-aci"
container_instance_subnet_address_prefix = "1.2.3.4/28" # must be a minimum size of `/28`

private_endpoint_subnet_name           = "private-endpoints"
private_endpoint_subnet_address_prefix = "1.2.3.4/28"

compute_types = ["azure_container_app"]

tags = { # NOTE: Add this to avoid removing tags that have been inherited from the resource group (on subsequent runs)
  account_coding = "000000000000000000000000"
  billing_group  = "abc123"
  ministry_name  = "MINISTRY_NAME"
}
