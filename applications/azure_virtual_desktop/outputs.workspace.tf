output "workspaces" {
  description = "Map of Azure Virtual Desktop workspaces keyed by var.workspaces."
  value = {
    for key, workspace in module.workspaces : key => {
      id            = workspace.id
      name          = workspace.name
      friendly_name = workspace.friendly_name
    }
  }
}

output "application_groups" {
  description = "Map of Azure Virtual Desktop application groups keyed by var.application_groups."
  value = {
    for key, application_group in module.application_groups : key => {
      id           = application_group.id
      name         = application_group.name
      type         = application_group.type
      host_pool_id = application_group.host_pool_id
    }
  }
}

output "workspace_application_group_associations" {
  description = "Map of workspace-to-application-group associations keyed by workspace_key.application_group_key."
  value = {
    for key, association in azurerm_virtual_desktop_workspace_application_group_association.this : key => {
      workspace_id         = association.workspace_id
      application_group_id = association.application_group_id
    }
  }
}
