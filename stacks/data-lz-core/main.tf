module "data_lz_core" {
  source = "../../modules/data-lz-core"

  providers = {
    azurerm     = azurerm
    azurerm.hub = azurerm.hub
  }

  location                  = var.location
  resource_group_name        = var.resource_group_name
  tags                      = var.tags
  allow_resource_group_destroy = var.allow_resource_group_destroy

  vnet                       = var.vnet
  subnets                    = var.subnets

  hub_connectivity           = var.hub_connectivity
  private_dns                = var.private_dns
  key_vault                  = var.key_vault
}
