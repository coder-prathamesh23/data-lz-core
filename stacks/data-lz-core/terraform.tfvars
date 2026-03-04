# -----------------------
# Core stack config
location                     = "westus3"
resource_group_name          = "rg-dp-lz-core"
allow_resource_group_destroy = false

# -----------------------
# Networking (Cloud Services managed)
# Provide either IDs OR names (recommended) for data lookups.

# Option A : provide names so Terraform reads IDs via data sources
spoke_vnet = {
  name                = ""   # Cloud Services will provide
  resource_group_name = ""   # Cloud Services will provide
}

workload_subnet = {
  name = ""  # Cloud Services will provide
  # virtual_network_name and resource_group_name can be omitted if same as spoke_vnet
}

private_endpoints_subnet = {
  name = ""  # Cloud Services will provide
  # virtual_network_name and resource_group_name can be omitted if same as spoke_vnet
}

# Option B: provide IDs directly 
# spoke_vnet = { id = "" }
# workload_subnet = { id = "" }
# private_endpoints_subnet = { id = "" }

# -----------------------
# Key Vault baseline
key_vault = {
  enabled                       = true
  name                          = "kv-dp-lz-core-01"
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false
}

tags = {
  workorder  = "TBD"
  costcenter = "TBD"
}
