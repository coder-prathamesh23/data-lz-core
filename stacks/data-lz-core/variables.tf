variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westus3"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the landing zone resources."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources."
  default     = {}
}

variable "allow_resource_group_destroy" {
  type        = bool
  description = "If true, the landing zone resource group is not protected by prevent_destroy."
  default     = false
}

# ---------------------------
# Subscription context (service connection)
# ---------------------------

variable "spoke_subscription_id" {
  type        = string
  description = "Subscription ID where the landing zone (spoke) resources are deployed."
}

variable "hub_subscription_id" {
  type        = string
  description = "Subscription ID where vWAN / vHub (hub) resources live."
}

# ---------------------------
# Spoke networking
# ---------------------------

variable "network_mode" {
  description = "Controls whether the spoke network is created by this stack or referenced via data sources. Allowed values: create, import."
  type        = string
  default     = "import"

  validation {
    condition     = contains(["create", "import"], var.network_mode)
    error_message = "network_mode must be one of: create, import."
  }
}

# ---- Import mode inputs (existing network)

variable "spoke_vnet" {
  description = "Existing spoke VNet reference (import mode). Provide either id OR (name + resource_group_name)."
  type = object({
    id                  = optional(string)
    name                = optional(string)
    resource_group_name = optional(string)
  })
  default = {}
}

variable "workload_subnet" {
  description = "Existing workload subnet reference (import mode). Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })
  default = {}
}

variable "private_endpoints_subnet" {
  description = "Existing private endpoints subnet reference (import mode). Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })
  default = {}
}

# ---- Create mode inputs (new network)

variable "spoke_vnet_name" {
  description = "Spoke VNet name (create mode)."
  type        = string
  default     = ""
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space (create mode)."
  type        = list(string)
  default     = []
}

variable "spoke_vnet_dns_servers" {
  description = "Custom DNS servers for the spoke VNet (central resolver/forwarder). Leave empty to use Azure defaults."
  type        = list(string)
  default     = []
}

variable "workload_subnet_name" {
  description = "Workload subnet name (create mode)."
  type        = string
  default     = ""
}

variable "workload_subnet_address_prefixes" {
  description = "Workload subnet address prefixes (create mode)."
  type        = list(string)
  default     = []
}

variable "private_endpoints_subnet_name" {
  description = "Private endpoints subnet name (create mode)."
  type        = string
  default     = ""
}

variable "private_endpoints_subnet_address_prefixes" {
  description = "Private endpoints subnet address prefixes (create mode)."
  type        = list(string)
  default     = []
}

# ---------------------------
# Optional baseline resources
# ---------------------------

variable "key_vault" {
  description = "Optional baseline Key Vault."
  type = object({
    enabled                       = bool
    name                          = string
    sku_name                      = optional(string, "standard")
    purge_protection_enabled      = optional(bool, true)
    soft_delete_retention_days    = optional(number, 7)
    public_network_access_enabled = optional(bool, false)
  })
  default = {
    enabled = false
    name    = ""
  }
}

# ---------------------------
# vWAN / vHub connectivity (Cloud Services provided)
# ---------------------------

variable "enable_vhub_connection" {
  type        = bool
  description = "If true, create vHub ↔ spoke VNet connection."
  default     = false
}

variable "hub_virtual_hub_id" {
  type        = string
  description = "Virtual Hub (vHub) resource ID to connect the spoke VNet to."
  default     = ""
}

variable "hub_vwan_name" {
  type        = string
  description = "Virtual WAN name (reference)."
  default     = ""
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub VNet name (reference)."
  default     = ""
}

variable "hub_vnet_resource_group" {
  type        = string
  description = "Hub VNet resource group (reference)."
  default     = ""
}

variable "hub_vnet_id" {
  type        = string
  description = "Hub VNet resource ID (reference)."
  default     = ""
}

variable "vhub_connection_name" {
  type        = string
  description = "Name of the vHub connection resource."
  default     = "conn-spoke-to-vhub"
}

variable "internet_security_enabled" {
  type        = bool
  description = "When true, the vHub connection propagates the default route as confirmed by Cloud Services."
  default     = true
}

# ---------------------------
# Private endpoints (ADLS) + central Private DNS zones
# ---------------------------

variable "enable_adls_private_endpoints" {
  type        = bool
  description = "If true, we create private endpoints for ADLS (dfs + blob) and attach them to central Private DNS zones."
  default     = false
}

variable "adls_storage_account_id" {
  type        = string
  description = "Resource ID of the ADLS Gen2 Storage Account."
  default     = ""
}

variable "adls_private_endpoint_name_prefix" {
  type        = string
  description = "Base name for the ADLS private endpoints. We append -dfs / -blob."
  default     = "pe-adls"
}

variable "adls_private_dns_zone_id_dfs" {
  type        = string
  description = "Central Private DNS zone ID for privatelink.dfs.core.windows.net."
  default     = ""
}

variable "adls_private_dns_zone_id_blob" {
  type        = string
  description = "Central Private DNS zone ID for privatelink.blob.core.windows.net."
  default     = ""
}
