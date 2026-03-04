data "azurerm_client_config" "current" {}

# ---------------------------
# Resource Group (protected by default)
# Terraform does not allow variables inside lifecycle.prevent_destroy.
# Use two mutually-exclusive RG resources and select via count.
# ---------------------------
resource "azurerm_resource_group" "protected" {
  count    = var.allow_resource_group_destroy ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_resource_group" "unprotected" {
  count    = var.allow_resource_group_destroy ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  rg_name = var.resource_group_name
  rg_id   = var.allow_resource_group_destroy ? azurerm_resource_group.unprotected[0].id : azurerm_resource_group.protected[0].id
}

# ---------------------------
# Spoke Network (Cloud Services managed) - IDs supplied via tfvars
# ---------------------------

locals {
  spoke_vnet_id               = var.spoke_vnet_id
  workload_subnet_id          = var.workload_subnet_id
  private_endpoints_subnet_id = var.private_endpoints_subnet_id
}

# ---------------------------
# Optional Key Vault baseline
# ---------------------------
resource "azurerm_key_vault" "this" {
  count               = var.key_vault.enabled ? 1 : 0
  name                = var.key_vault.name
  location            = var.location
  resource_group_name = local.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = try(var.key_vault.sku_name, "standard")

  purge_protection_enabled      = try(var.key_vault.purge_protection_enabled, true)
  soft_delete_retention_days    = try(var.key_vault.soft_delete_retention_days, 7)
  public_network_access_enabled = try(var.key_vault.public_network_access_enabled, false)

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.key_vault.enabled == false || (var.key_vault.enabled == true && var.key_vault.name != "")
      error_message = "When key_vault.enabled is true, key_vault.name must be set."
    }
  }
}
