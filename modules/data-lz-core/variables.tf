variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Spoke resource group name."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}

variable "allow_resource_group_destroy" {
  type        = bool
  description = "If true, resource group is not protected by prevent_destroy."
  default     = false
}

# ---------------------------
# Spoke Network (Cloud Services managed) - IDs provided by caller (stack)
# ---------------------------
variable "spoke_vnet_id" {
  description = "Existing spoke VNet ID (provided by Cloud Services)."
  type        = string
}

variable "workload_subnet_id" {
  description = "Existing workload subnet ID (provided by Cloud Services)."
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "Existing private endpoints subnet ID (provided by Cloud Services)."
  type        = string
}

# ---------------------------
# Optional baseline resources
# ---------------------------
variable "key_vault" {
  type = object({
    enabled                        = bool
    name                           = string
    sku_name                       = optional(string, "standard")
    purge_protection_enabled       = optional(bool, true)
    soft_delete_retention_days     = optional(number, 7)
    public_network_access_enabled  = optional(bool, false)
  })
}
