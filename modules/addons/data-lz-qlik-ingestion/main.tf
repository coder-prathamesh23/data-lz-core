resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  min_tls_version = "TLS1_2"

  # Security hardening knobs (Azure Portal: "Allow blob public access" and "Allow storage account key access").
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  # Lock down public access. Storage should be reachable via private endpoints only.
  public_network_access_enabled = false

  # Defense-in-depth: deny any public network traffic even if public access gets re-enabled later.
  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# Private Endpoint for Blob
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.name_prefix}-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoints
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = try(var.private_dns_zone_ids["blob"], "") != "" ? [1] : []
    content {
      name                 = "blob"
      private_dns_zone_ids = [var.private_dns_zone_ids["blob"]]
    }
  }
}

# Private Endpoint for DFS (ADLS Gen2)
resource "azurerm_private_endpoint" "dfs" {
  name                = "${var.name_prefix}-pe-dfs"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoints
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-psc-dfs"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = try(var.private_dns_zone_ids["dfs"], "") != "" ? [1] : []
    content {
      name                 = "dfs"
      private_dns_zone_ids = [var.private_dns_zone_ids["dfs"]]
    }
  }
}
