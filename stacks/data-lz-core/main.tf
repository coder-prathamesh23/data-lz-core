# ---------------------------------------------------------
# Networking (Cloud Services managed)
# - Do NOT create VNet/subnets/Private DNS links here.
# - Read existing objects so the module can still get the IDs it needs.
# ---------------------------------------------------------

# Spoke VNet lookup (only if ID is not provided)
data "azurerm_virtual_network" "spoke" {
  count               = try(var.spoke_vnet.id, null) == null ? 1 : 0
  name                = var.spoke_vnet.name
  resource_group_name = var.spoke_vnet.resource_group_name
}

# Workload subnet lookup (only if ID is not provided)
data "azurerm_subnet" "workload" {
  count                = try(var.workload_subnet.id, null) == null ? 1 : 0
  name                 = var.workload_subnet.name
  virtual_network_name = coalesce(try(var.workload_subnet.virtual_network_name, null), try(var.spoke_vnet.name, null))
  resource_group_name  = coalesce(try(var.workload_subnet.resource_group_name, null), try(var.spoke_vnet.resource_group_name, null))
}

# Private Endpoints subnet lookup (only if ID is not provided)
data "azurerm_subnet" "private_endpoints" {
  count                = try(var.private_endpoints_subnet.id, null) == null ? 1 : 0
  name                 = var.private_endpoints_subnet.name
  virtual_network_name = coalesce(try(var.private_endpoints_subnet.virtual_network_name, null), try(var.spoke_vnet.name, null))
  resource_group_name  = coalesce(try(var.private_endpoints_subnet.resource_group_name, null), try(var.spoke_vnet.resource_group_name, null))
}

locals {
  spoke_vnet_id = coalesce(
    try(var.spoke_vnet.id, null),
    try(data.azurerm_virtual_network.spoke[0].id, null)
  )

  workload_subnet_id = coalesce(
    try(var.workload_subnet.id, null),
    try(data.azurerm_subnet.workload[0].id, null)
  )

  private_endpoints_subnet_id = coalesce(
    try(var.private_endpoints_subnet.id, null),
    try(data.azurerm_subnet.private_endpoints[0].id, null)
  )
}

module "data_lz_core" {
  source = "../../modules/data-lz-core"

  providers = {
    azurerm = azurerm
  }

  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  allow_resource_group_destroy = var.allow_resource_group_destroy

  # Cloud Services managed network (read-only)
  spoke_vnet_id               = local.spoke_vnet_id
  workload_subnet_id          = local.workload_subnet_id
  private_endpoints_subnet_id = local.private_endpoints_subnet_id

  key_vault = var.key_vault
}
