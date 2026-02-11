name_prefix = "dp-qlik"
location    = "westus3"

resource_group_name = "rg-dp-qlik-ingestion"

# Fill in:
storage_account_name        = "stqdpqlikingest01"
subnet_id_private_endpoints = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/snet-private-endpoints"

# If your Private DNS zones are in a central hub subscription:
hub_subscription_id     = ""
hub_private_dns_rg_name = "rg-hub-dns-azuconnectivity-flz-westus3"
