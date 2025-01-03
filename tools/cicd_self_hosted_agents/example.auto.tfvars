resource_group_name = "caf-ghr"
location            = "Canada Central"

postfix = "ghr"

version_control_system_type         = "github"
version_control_system_organization = "bcgov-c"         # The organization name in the version control system
version_control_system_repository   = "REPOSITORY_NAME" # The repository name in the version control system
# export TF_VAR_github_personal_access_token=<your_github_personal_access_token>

virtual_network_resource_group = "VNET_RG"
virtual_network_name           = "VNET_NAME"
container_app_subnet_name      = "ACA_SUBNET" # must be delegated to the service 'Microsoft.App/environments'
container_instance_subnet_name = "ACI_SUBNET" # must be delegated to the service 'Microsoft.ContainerInstance/containerGroups'
private_endpoint_subnet_name   = "PE_SUBNET"

compute_types = ["azure_container_app"]
