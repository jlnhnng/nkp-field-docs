output "vm_name" {
  description = "Bootstrap VM name"
  value       = nutanix_virtual_machine_v2.bootstrap.name
}

output "vm_ext_id" {
  description = "Prism Central external ID of the bootstrap VM"
  value       = nutanix_virtual_machine_v2.bootstrap.id
}

output "vm_ip_address" {
  description = "Primary IPv4 address assigned to the VM"
  value = try(
    nutanix_virtual_machine_v2.bootstrap.nics[0].nic_network_info[0].virtual_ethernet_nic_network_info[0].ipv4_config[0].ip_address[0].value,
    "not yet assigned — run 'tofu refresh' after the VM boots"
  )
}
