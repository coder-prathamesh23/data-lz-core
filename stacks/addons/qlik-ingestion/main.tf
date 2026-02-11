# Optionally lookup central Private DNS zones to attach to private endpoints
data "azurerm_private_dns_zone" "blob" {
  count               = var.hub_private_dns_rg_name != "" ? 1 : 0
  provider            = azurerm.hub
  name                = var.private_dns_zone_names["blob"]
  resource_group_name = var.hub_private_dns_rg_name
}

data "azurerm_private_dns_zone" "dfs" {
  count               = var.hub_private_dns_rg_name != "" ? 1 : 0
  provider            = azurerm.hub
  name                = var.private_dns_zone_names["dfs"]
  resource_group_name = var.hub_private_dns_rg_name
}

locals {
  zone_ids = var.hub_private_dns_rg_name != "" ? {
    blob = data.azurerm_private_dns_zone.blob[0].id
    dfs  = data.azurerm_private_dns_zone.dfs[0].id
  } : {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "qlik" {
  source = "../../../modules/addons/data-lz-qlik-ingestion"

  name_prefix                 = var.name_prefix
  location                    = var.location
  resource_group_name         = azurerm_resource_group.this.name
  storage_account_name        = var.storage_account_name
  containers                  = var.containers
  subnet_id_private_endpoints = var.subnet_id_private_endpoints
  private_dns_zone_ids        = local.zone_ids
  tags                        = var.tags
}

output "qlik" { value = module.qlik }
