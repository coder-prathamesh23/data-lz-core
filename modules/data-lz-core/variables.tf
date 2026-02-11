variable "location" {
  type        = string
  description = "Azure region for the landing zone resources."
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

variable "vnet" {
  description = "Spoke VNet configuration."
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "subnets" {
  description = "Subnet map. Keys are subnet logical names; values define subnet settings."
  type = map(object({
    name                                      = string
    address_prefixes                          = list(string)
    service_endpoints                         = optional(list(string), [])
    delegations                               = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])

    # AzureRM v4 uses string policies on subnets ("Enabled"/"Disabled").
    private_endpoint_network_policies         = optional(string, "Disabled")
    private_link_service_network_policies     = optional(string, "Enabled")
  }))
}

variable "hub_connectivity" {
  description = "Hub connectivity settings. Choose vnet_peering or vwan_virtual_hub."
  type = object({
    enabled                 = bool
    connectivity_type       = string # "vnet_peering" | "vwan_virtual_hub"

    # Peering inputs
    hub_vnet_id             = optional(string, "")
    hub_vnet_name           = optional(string, "")
    hub_resource_group_name = optional(string, "")
    manage_hub_side_peering = optional(bool, false)

    # vWAN inputs
    virtual_hub_id                  = optional(string, "")
    virtual_hub_route_table_id      = optional(string, "")
    propagated_route_table_ids      = optional(list(string), [])
    labels                          = optional(list(string), [])
  })
  default = {
    enabled                 = false
    connectivity_type       = "vnet_peering"
    hub_vnet_id             = ""
    hub_vnet_name           = ""
    hub_resource_group_name = ""
    manage_hub_side_peering = false
    virtual_hub_id          = ""
    virtual_hub_route_table_id = ""
    propagated_route_table_ids = []
    labels = []
  }

  validation {
    condition = (
      var.hub_connectivity.enabled == false ||
      contains(["vnet_peering", "vwan_virtual_hub"], var.hub_connectivity.connectivity_type)
    )
    error_message = "hub_connectivity.connectivity_type must be one of: vnet_peering, vwan_virtual_hub."
  }
}

variable "private_dns" {
  description = "Private DNS link settings. Expects hub-managed zones; this module only creates VNet links."
  type = object({
    enabled                     = bool
    hub_private_dns_rg_name     = string
    zone_names                  = list(string) # e.g. privatelink.blob.core.windows.net
  })
  default = {
    enabled                 = false
    hub_private_dns_rg_name = ""
    zone_names              = []
  }
}

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
