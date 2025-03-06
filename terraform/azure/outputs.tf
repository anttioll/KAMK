output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.myapp.address_space
}

output "myapp_public_ip" {
  value = azurerm_public_ip.myapp.ip_address
}

output "myapp_admin_username" {
  value = azurerm_linux_virtual_machine.myapp.admin_username
}
