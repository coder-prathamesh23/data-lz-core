# -----------------------
# Core stack config
# -----------------------
location                     = "westus3"
resource_group_name          = "rg-dp-lz-core"
allow_resource_group_destroy = false

tags = {
  workorder  = "TBD"
  costcenter = "TBD"
}

# -----------------------
# Subscription context (Cloud Services service connection)
# -----------------------
spoke_subscription_id = "<adrian-provided-spoke-subscription-id>"
hub_subscription_id   = "<adrian-provided-hub-subscription-id>"

# -----------------------
# Spoke networking
# -----------------------

# We switch between create/import. For this landing zone we are proceeding with create.
network_mode = "create"

# --- create mode inputs
spoke_vnet_name          = "vnet-dp-lz-core"
spoke_vnet_address_space = ["10.50.0.0/16"]

# Central DNS servers (Cloud Services will provide the IPs)
# Example:
# spoke_vnet_dns_servers = ["10.0.0.4", "10.0.0.5"]
spoke_vnet_dns_servers = []

workload_subnet_name             = "snet-workload"
workload_subnet_address_prefixes = ["10.50.1.0/24"]

private_endpoints_subnet_name             = "snet-private-endpoints"
private_endpoints_subnet_address_prefixes = ["10.50.2.0/24"]

# --- import mode inputs (kept for later; not used when network_mode=create)
# spoke_vnet = {
#   name                = "<cloud-services-provided-vnet-name>"
#   resource_group_name = "<cloud-services-provided-vnet-rg>"
# }
#
# workload_subnet = {
#   name = "<cloud-services-provided-workload-subnet-name>"
# }
#
# private_endpoints_subnet = {
#   name = "<cloud-services-provided-pe-subnet-name>"
# }

# -----------------------
# Key Vault baseline
# -----------------------
key_vault = {
  enabled                       = true
  name                          = "kv-dp-lz-core-01"
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false
}

# -----------------------
# vWAN / vHub connectivity (provided by Cloud Services)
# -----------------------
enable_vhub_connection = true

hub_virtual_hub_id      = "<adrian-provided-vhub-id>"
hub_vwan_name           = "<adrian-provided-vwan-name>"
hub_vnet_name           = "<adrian-provided-hub-vnet-name>"
hub_vnet_resource_group = "<adrian-provided-hub-vnet-rg>"
hub_vnet_id             = "<adrian-provided-hub-vnet-id>"

vhub_connection_name = "conn-dp-spoke-to-hub"

# We keep this false until Cameron confirms the expected setting.
vhub_propagate_default_route = false

# This stays false unless Cloud Services explicitly asks for it.
internet_security_enabled = false

# -----------------------
# Private Endpoints (ADLS) + Central Private DNS zones
# -----------------------

# We keep this disabled until Adrian provides the Storage Account ID and the central Private DNS zone IDs.
enable_adls_private_endpoints = false

adls_storage_account_id = "<adrian-provided-adls-storage-account-id>"

# Central private DNS zone IDs (Cloud Services will provide)
adls_private_dns_zone_id_dfs  = "<adrian-provided-privatelink-dfs-zone-id>"
adls_private_dns_zone_id_blob = "<adrian-provided-privatelink-blob-zone-id>"

# Optional: override PE naming
adls_private_endpoint_name_prefix = "pe-adls"
