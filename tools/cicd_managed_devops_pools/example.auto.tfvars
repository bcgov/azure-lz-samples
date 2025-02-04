resource_group_name = "managed-devops-pools"
location            = "Canada Central"

virtual_network_resource_group            = "abc123-dev-networking"
virtual_network_name                      = "abc123-dev-vwan-spoke"
managed_devops_pool_subnet_name           = "devops-pool"
managed_devops_pool_subnet_address_prefix = "10.41.0.0/28"

version_control_system_organization_name = "managed-pool-test"      # Azure DevOps Organiation Name
version_control_system_project_names     = ["Managed Pool Project"] # Azure DevOps Project Names

dev_center_name                = "managed-devops-pool"
dev_center_project_name        = "managed-devops-pool"
dev_center_project_description = "Managed DevOps Pool"
managed_devops_pool_name       = "managed-devops-pool"
