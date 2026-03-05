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
#
# We support two workflows:
#   - import: Cloud Services pre-creates VNet/subnets and we only reference them
#   - create: we create VNet/subnets as part of this stack, executed by Cloud Services identity
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
  description = "Existing spoke VNet reference. Used only when network_mode=import. Provide either id OR (name + resource_group_name)."
  type = object({
    id                  = optional(string)
    name                = optional(string)
    resource_group_name = optional(string)
  })
  default = {}

  validation {
    condition = (
      var.network_mode != "import" ||
      try(var.spoke_vnet.id, null) != null ||
      (
        try(var.spoke_vnet.name, null) != null &&
        try(var.spoke_vnet.resource_group_name, null) != null
      )
    )
    error_message = "When network_mode=import, provide spoke_vnet.id OR (spoke_vnet.name + spoke_vnet.resource_group_name)."
  }
}

variable "workload_subnet" {
  description = "Existing workload subnet reference. Used only when network_mode=import. Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })
  default = {}

  validation {
    condition = (
      var.network_mode != "import" ||
      try(var.workload_subnet.id, null) != null ||
      (
        try(var.workload_subnet.name, null) != null &&
        (
          (
            try(var.workload_subnet.virtual_network_name, null) != null &&
            try(var.workload_subnet.resource_group_name, null) != null
          ) ||
          (
            try(var.spoke_vnet.name, null) != null &&
            try(var.spoke_vnet.resource_group_name, null) != null
          )
        )
      )
    )
    error_message = "When network_mode=import, provide workload_subnet.id OR workload_subnet.name and ensure vnet/rg are provided (directly or via spoke_vnet)."
  }
}

variable "private_endpoints_subnet" {
  description = "Existing private endpoints subnet reference. Used only when network_mode=import. Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })
  default = {}

  validation {
    condition = (
      var.network_mode != "import" ||
      try(var.private_endpoints_subnet.id, null) != null ||
      (
        try(var.private_endpoints_subnet.name, null) != null &&
        (
          (
            try(var.private_endpoints_subnet.virtual_network_name, null) != null &&
            try(var.private_endpoints_subnet.resource_group_name, null) != null
          ) ||
          (
            try(var.spoke_vnet.name, null) != null &&
            try(var.spoke_vnet.resource_group_name, null) != null
          )
        )
      )
    )
    error_message = "When network_mode=import, provide private_endpoints_subnet.id OR private_endpoints_subnet.name and ensure vnet/rg are provided (directly or via spoke_vnet)."
  }
}

# ---- Create mode inputs (new network)

variable "spoke_vnet_name" {
  description = "Spoke VNet name. Used only when network_mode=create."
  type        = string
  default     = ""

  validation {
    condition     = var.network_mode != "create" || var.spoke_vnet_name != ""
    error_message = "When network_mode=create, spoke_vnet_name must be set."
  }
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space. Used only when network_mode=create."
  type        = list(string)
  default     = []

  validation {
    condition     = var.network_mode != "create" || length(var.spoke_vnet_address_space) > 0
    error_message = "When network_mode=create, spoke_vnet_address_space must contain at least one CIDR."
  }
}

variable "spoke_vnet_dns_servers" {
  description = "Custom DNS servers for the spoke VNet (central resolver/forwarder). Leave empty to use Azure defaults."
  type        = list(string)
  default     = []
}

variable "workload_subnet_name" {
  description = "Workload subnet name. Used only when network_mode=create."
  type        = string
  default     = ""

  validation {
    condition     = var.network_mode != "create" || var.workload_subnet_name != ""
    error_message = "When network_mode=create, workload_subnet_name must be set."
  }
}

variable "workload_subnet_address_prefixes" {
  description = "Workload subnet address prefixes. Used only when network_mode=create."
  type        = list(string)
  default     = []

  validation {
    condition     = var.network_mode != "create" || length(var.workload_subnet_address_prefixes) > 0
    error_message = "When network_mode=create, workload_subnet_address_prefixes must contain at least one CIDR."
  }
}

variable "private_endpoints_subnet_name" {
  description = "Private endpoints subnet name. Used only when network_mode=create."
  type        = string
  default     = ""

  validation {
    condition     = var.network_mode != "create" || var.private_endpoints_subnet_name != ""
    error_message = "When network_mode=create, private_endpoints_subnet_name must be set."
  }
}

variable "private_endpoints_subnet_address_prefixes" {
  description = "Private endpoints subnet address prefixes. Used only when network_mode=create."
  type        = list(string)
  default     = []

  validation {
    condition     = var.network_mode != "create" || length(var.private_endpoints_subnet_address_prefixes) > 0
    error_message = "When network_mode=create, private_endpoints_subnet_address_prefixes must contain at least one CIDR."
  }
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

# These are informational inputs from Cloud Services. We keep them in tfvars for clarity and troubleshooting.
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

# Cameron confirmed this ensures "Propagate Default Route" is set on the vHub connection.
variable "internet_security_enabled" {
  type        = bool
  description = "When true, the vHub connection advertises the default route across vWAN per the current hub configuration."
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
  description = "Central Private DNS zone ID for privatelink.dfs.core.windows.net (provided by Cloud Services)."
  default     = ""
}

variable "adls_private_dns_zone_id_blob" {
  type        = string
  description = "Central Private DNS zone ID for privatelink.blob.core.windows.net (provided by Cloud Services)."
  default     = ""
}
