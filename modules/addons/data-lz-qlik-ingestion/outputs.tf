output "storage_account_id" { value = azurerm_storage_account.this.id }
output "storage_account_name" { value = azurerm_storage_account.this.name }
output "private_endpoints" {
  value = {
    blob = azurerm_private_endpoint.blob.id
    dfs  = azurerm_private_endpoint.dfs.id
  }
}
