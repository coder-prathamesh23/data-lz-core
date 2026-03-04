output "resource_group_id" {
  value       = local.rg_id
  description = "Resource group ID for the landing zone."
}

output "spoke_vnet_id" {
  value       = var.spoke_vnet_id
  description = "Spoke VNet ID (Cloud Services managed)."
}

output "workload_subnet_id" {
  value       = var.workload_subnet_id
  description = "Workload subnet ID (Cloud Services managed)."
}

output "private_endpoints_subnet_id" {
  value       = var.private_endpoints_subnet_id
  description = "Private endpoints subnet ID (Cloud Services managed)."
}

output "key_vault_id" {
  value       = try(azurerm_key_vault.this[0].id, null)
  description = "Key Vault ID (if enabled)."
}
