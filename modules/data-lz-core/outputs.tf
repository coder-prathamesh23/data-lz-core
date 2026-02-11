output "resource_group_id" {
  value       = local.rg_id
  description = "Resource group ID for the landing zone."
}

output "vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "Spoke VNet ID."
}

output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.this : k => s.id }
  description = "Map of subnet ids."
}

output "key_vault_id" {
  value       = try(azurerm_key_vault.this[0].id, null)
  description = "Key Vault ID (if enabled)."
}
