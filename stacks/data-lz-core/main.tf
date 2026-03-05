# ---------------------------
# Resource Group (protected by default)
# Terraform does not allow variables inside lifecycle.prevent_destroy.
# We use two mutually-exclusive RG resources and select via count.
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
  rg_name = var.allow_resource_group_destroy ? azurerm_resource_group.unprotected[0].name : azurerm_resource_group.protected[0].name
  rg_id   = var.allow_resource_group_destroy ? azurerm_resource_group.unprotected[0].id : azurerm_resource_group.protected[0].id
}

# ---------------------------
# Spoke Networking
# ---------------------------

# Import mode: read an existing VNet/subnets

data "azurerm_virtual_network" "spoke" {
  count               = var.network_mode == "import" && try(var.spoke_vnet.id, null) == null ? 1 : 0
  name                = var.spoke_vnet.name
  resource_group_name = var.spoke_vnet.resource_group_name
}

data "azurerm_subnet" "workload" {
  count                = var.network_mode == "import" && try(var.workload_subnet.id, null) == null ? 1 : 0
  name                 = var.workload_subnet.name
  virtual_network_name = coalesce(try(var.workload_subnet.virtual_network_name, null), try(var.spoke_vnet.name, null))
  resource_group_name  = coalesce(try(var.workload_subnet.resource_group_name, null), try(var.spoke_vnet.resource_group_name, null))
}

data "azurerm_subnet" "private_endpoints" {
  count                = var.network_mode == "import" && try(var.private_endpoints_subnet.id, null) == null ? 1 : 0
  name                 = var.private_endpoints_subnet.name
  virtual_network_name = coalesce(try(var.private_endpoints_subnet.virtual_network_name, null), try(var.spoke_vnet.name, null))
  resource_group_name  = coalesce(try(var.private_endpoints_subnet.resource_group_name, null), try(var.spoke_vnet.resource_group_name, null))
}

# Create mode: build a new VNet/subnets in the landing zone RG

resource "azurerm_virtual_network" "spoke" {
  count               = var.network_mode == "create" ? 1 : 0
  name                = var.spoke_vnet_name
  location            = var.location
  resource_group_name = local.rg_name
  address_space       = var.spoke_vnet_address_space
  dns_servers         = var.spoke_vnet_dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  count                = var.network_mode == "create" ? 1 : 0
  name                 = var.workload_subnet_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = var.workload_subnet_address_prefixes
}

resource "azurerm_subnet" "private_endpoints" {
  count                = var.network_mode == "create" ? 1 : 0
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = var.private_endpoints_subnet_address_prefixes

  # Private endpoints require network policies to be disabled on the PE subnet.
  private_endpoint_network_policies = "Disabled"
}

locals {
  spoke_vnet_id = coalesce(
    try(azurerm_virtual_network.spoke[0].id, null),
    try(var.spoke_vnet.id, null),
    try(data.azurerm_virtual_network.spoke[0].id, null)
  )

  workload_subnet_id = coalesce(
    try(azurerm_subnet.workload[0].id, null),
    try(var.workload_subnet.id, null),
    try(data.azurerm_subnet.workload[0].id, null)
  )

  private_endpoints_subnet_id = coalesce(
    try(azurerm_subnet.private_endpoints[0].id, null),
    try(var.private_endpoints_subnet.id, null),
    try(data.azurerm_subnet.private_endpoints[0].id, null)
  )
}

# ---------------------------
# Core landing zone resources (application subscription baseline)
# ---------------------------

module "data_lz_core" {
  source = "../../modules/data-lz-core"

  providers = {
    azurerm = azurerm
  }

  location            = var.location
  resource_group_name = local.rg_name
  tags                = var.tags

  spoke_vnet_id               = local.spoke_vnet_id
  workload_subnet_id          = local.workload_subnet_id
  private_endpoints_subnet_id = local.private_endpoints_subnet_id

  key_vault = var.key_vault
}

# ---------------------------
# vWAN / vHub connectivity
# ---------------------------

resource "azurerm_virtual_hub_connection" "spoke" {
  count = var.enable_vhub_connection ? 1 : 0

  name                      = var.vhub_connection_name
  virtual_hub_id            = var.hub_virtual_hub_id
  remote_virtual_network_id = local.spoke_vnet_id

  # We keep this controlled with explicit flags. When vhub_propagate_default_route is true,
  # we enable the supported connection setting that results in default route advertisement.
  internet_security_enabled = var.internet_security_enabled

  provider = azurerm.hub

  lifecycle {
    precondition {
      condition     = var.hub_virtual_hub_id != null && var.hub_virtual_hub_id != ""
      error_message = "enable_vhub_connection=true but hub_virtual_hub_id is empty."
    }

    precondition {
      condition     = local.spoke_vnet_id != null && local.spoke_vnet_id != ""
      error_message = "Spoke VNet ID could not be resolved."
    }
  }
}

# ---------------------------
# Private endpoints (ADLS) + central Private DNS zones
# ---------------------------

resource "azurerm_private_endpoint" "adls_dfs" {
  count               = var.enable_adls_private_endpoints ? 1 : 0
  name                = "${var.adls_private_endpoint_name_prefix}-dfs"
  location            = var.location
  resource_group_name = local.rg_name
  subnet_id           = local.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.adls_private_endpoint_name_prefix}-dfs"
    private_connection_resource_id = var.adls_storage_account_id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "adls-dfs"
    private_dns_zone_ids = [var.adls_private_dns_zone_id_dfs]
  }

  lifecycle {
    precondition {
      condition     = var.adls_storage_account_id != ""
      error_message = "enable_adls_private_endpoints=true but adls_storage_account_id is empty."
    }

    precondition {
      condition     = var.adls_private_dns_zone_id_dfs != ""
      error_message = "enable_adls_private_endpoints=true but adls_private_dns_zone_id_dfs is empty."
    }

    precondition {
      condition     = local.private_endpoints_subnet_id != null && local.private_endpoints_subnet_id != ""
      error_message = "Private endpoints subnet ID could not be resolved."
    }
  }
}

resource "azurerm_private_endpoint" "adls_blob" {
  count               = var.enable_adls_private_endpoints ? 1 : 0
  name                = "${var.adls_private_endpoint_name_prefix}-blob"
  location            = var.location
  resource_group_name = local.rg_name
  subnet_id           = local.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.adls_private_endpoint_name_prefix}-blob"
    private_connection_resource_id = var.adls_storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "adls-blob"
    private_dns_zone_ids = [var.adls_private_dns_zone_id_blob]
  }

  lifecycle {
    precondition {
      condition     = var.adls_storage_account_id != ""
      error_message = "enable_adls_private_endpoints=true but adls_storage_account_id is empty."
    }

    precondition {
      condition     = var.adls_private_dns_zone_id_blob != ""
      error_message = "enable_adls_private_endpoints=true but adls_private_dns_zone_id_blob is empty."
    }

    precondition {
      condition     = local.private_endpoints_subnet_id != null && local.private_endpoints_subnet_id != ""
      error_message = "Private endpoints subnet ID could not be resolved."
    }
  }
}
