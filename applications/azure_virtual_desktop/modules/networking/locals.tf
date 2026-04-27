locals {
  network_security_rules = {
    for rule in flatten([
      for network_security_group_key, network_security_group in var.network_security_groups : [
        for rule_key, security_rule in network_security_group.security_rules : merge(security_rule, {
          key                        = "${network_security_group_key}.${rule_key}"
          name                       = coalesce(try(security_rule.name, null), rule_key)
          network_security_group_key = network_security_group_key
        })
      ]
    ]) : rule.key => rule
  }
}
