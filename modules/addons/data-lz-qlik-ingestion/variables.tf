variable "name_prefix" {
  type        = string
  description = "Name prefix used for resource naming."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name where add-on resources will be created."
}

variable "storage_account_id" {
  type        = string
  description = "Optional existing storage account id. If null, the module creates a new storage account."
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name for Qlik ingestion."
}

variable "containers" {
  type        = list(string)
  description = "Containers to create."
  default     = ["qlik-ingestion"]
}

variable "subnet_id_private_endpoints" {
  type        = string
  description = "Subnet id where Private Endpoints will be placed."
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Map of Private DNS zone ids for PE zone groups. Expected keys: blob, dfs. If omitted/empty, DNS zone group is skipped."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
