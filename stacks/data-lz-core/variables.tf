variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westus3"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the landing zone (spoke) resources."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources."
  default     = {}
}

variable "allow_resource_group_destroy" {
  type        = bool
  description = "If true, RG is not protected by prevent_destroy. Default false (protected)."
  default     = false
}

# ---------------------------
# Networking (Cloud Services managed)
# ---------------------------

variable "spoke_vnet" {
  description = "Existing spoke VNet reference (Cloud Services managed). Provide either id OR (name + resource_group_name)."
  type = object({
    id                  = optional(string)
    name                = optional(string)
    resource_group_name = optional(string)
  })

  validation {
    condition = (
      try(var.spoke_vnet.id, null) != null ||
      (
        try(var.spoke_vnet.name, null) != null &&
        try(var.spoke_vnet.resource_group_name, null) != null
      )
    )
    error_message = "spoke_vnet: provide either spoke_vnet.id OR (spoke_vnet.name + spoke_vnet.resource_group_name)."
  }
}

variable "workload_subnet" {
  description = "Existing workload subnet reference (Cloud Services managed). Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })

  validation {
    condition = (
      try(var.workload_subnet.id, null) != null ||
      (
        try(var.workload_subnet.name, null) != null &&
        (
          # either explicitly set vnet+rg OR let it be derived from spoke_vnet
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
    error_message = "workload_subnet: provide either workload_subnet.id OR workload_subnet.name and ensure vnet/rg are provided (directly or via spoke_vnet)."
  }
}

variable "private_endpoints_subnet" {
  description = "Existing private endpoints subnet reference (Cloud Services managed). Provide either id OR (name + vnet/rg resolvable)."
  type = object({
    id                   = optional(string)
    name                 = optional(string)
    virtual_network_name = optional(string)
    resource_group_name  = optional(string)
  })

  validation {
    condition = (
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
    error_message = "private_endpoints_subnet: provide either private_endpoints_subnet.id OR private_endpoints_subnet.name and ensure vnet/rg are provided (directly or via spoke_vnet)."
  }
}

# ---------------------------
# Optional baseline resources
# ---------------------------
variable "key_vault" {
  description = "Optional baseline Key Vault."
  type = object({
    enabled                        = bool
    name                           = string
    sku_name                       = optional(string, "standard")
    purge_protection_enabled       = optional(bool, true)
    soft_delete_retention_days     = optional(number, 7)
    public_network_access_enabled  = optional(bool, false)
  })
  default = {
    enabled = false
    name    = ""
  }
}
