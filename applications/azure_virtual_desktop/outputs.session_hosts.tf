output "session_hosts" {
  description = "Map of Azure VM-based AVD session hosts keyed by session_hosts entry and instance number."
  value = {
    for key, session_host in module.session_hosts : key => {
      id                     = session_host.id
      name                   = session_host.name
      computer_name          = session_host.computer_name
      network_interface_id   = session_host.network_interface_id
      private_ip_address     = session_host.private_ip_address
      admin_username         = session_host.admin_username
      vm_role_assignment_ids = session_host.vm_role_assignment_ids
    }
  }
}

output "session_host_admin_passwords" {
  description = "Sensitive map of generated or supplied local administrator passwords for session hosts."
  value = {
    for key, session_host in module.session_hosts : key => session_host.admin_password
  }
  sensitive = true
}
