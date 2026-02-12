# -----------------------
# Stack identity
location                     = "westus3"
resource_group_name          = "rg-dp-lz-core"
allow_resource_group_destroy = false

tags = {
  workorder  = "TBD"
  costcenter = "TBD"
}

# -----------------------
# Networking (minimal)
vnet = {
  name          = "vnet-dp-lz"
  address_space = ["10.91.4.0/23"]
}

# One workload subnet + one private endpoint subnet (matches the diagram)
subnets = {
  workload = {
    name             = "snet-workload"
    address_prefixes = ["10.91.4.0/24"]
  }

  private_endpoints = {
    name             = "snet-private-endpoints"
    address_prefixes = ["10.91.5.0/26"]

    # AzureRM expects string values: "Enabled" / "Disabled"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = "Enabled"
  }
}

# -----------------------
# Hub connectivity
hub_connectivity = {
  enabled           = true
  connectivity_type = "vnet_peering" # or "vwan_virtual_hub"

  # If peering: prefer hub_vnet_id, otherwise provide hub_vnet_name + hub_resource_group_name
  hub_vnet_id             = ""
  hub_vnet_name           = ""
  hub_resource_group_name = ""
  manage_hub_side_peering = false

  # If vWAN: set virtual_hub_id (and optional route-table ids)
  virtual_hub_id             = ""
  virtual_hub_route_table_id = ""
  propagated_route_table_ids = []
  labels                     = []
}

# -----------------------
# Private DNS (central hub zones; this stack links the spoke VNet)
private_dns = {
  enabled                 = true
  hub_private_dns_rg_name = "rg-hub-dns-azuconnectivity-flz-westus3"
  zone_names = [
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
}

# -----------------------
# Key Vault baseline
key_vault = {
  enabled = true
  name    = "kv-dp-lz-core-01"

  # keep KV private by default
  public_network_access_enabled = false
}
