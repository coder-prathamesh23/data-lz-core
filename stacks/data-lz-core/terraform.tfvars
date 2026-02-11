# -----------------------
# Stack identity
name_prefix                  = "dp-lz"
location                     = "westus3"
resource_group_name          = "rg-dp-lz-core"
allow_resource_group_destroy = false

# -----------------------
# Networking (minimal)
vnet_name          = "vnet-dp-lz"
vnet_address_space = ["10.91.4.0/23"]
dns_servers        = ["172.22.7.4"]

# One workload subnet + one private endpoint subnet (matches the diagram)
subnets = {
  "snet-workload" = {
    address_prefixes = ["10.91.4.0/24"]
  }
  "snet-private-endpoints" = {
    address_prefixes                          = ["10.91.5.0/26"]
    private_endpoint_network_policies_enabled = true
  }
}

# -----------------------
# Hub connectivity
enable_hub_connectivity = true
connectivity_type       = "vnet_peering" # or "vwan_hub_connection"

# If peering:
hub_subscription_id     = "" # set if hub is in a different subscription
hub_vnet_id             = "" # recommended: set to full resource id
hub_vnet_name           = "" # needed if you want to manage hub->spoke peering
hub_resource_group_name = "" # needed if you want to manage hub->spoke peering

# If vWAN hub connection:
hub_virtual_hub_id = "" # set to /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualHubs/...

# -----------------------
# Private DNS (central)
enable_private_dns_links = true
hub_private_dns_rg_name  = "rg-hub-dns-azuconnectivity-flz-westus3"

private_dns_zones = [
  "privatelink.blob.core.windows.net",
  "privatelink.dfs.core.windows.net",
  "privatelink.vaultcore.azure.net"
]

# -----------------------
# Key Vault baseline
enable_key_vault = true
key_vault_name   = "kv-dp-lz-core-01"

tags = {
  workorder  = "TBD"
  costcenter = "TBD"
}
