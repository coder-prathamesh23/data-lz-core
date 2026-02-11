variable "name_prefix" {
  type    = string
  default = "dp-qlik"
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "resource_group_name" {
  type    = string
  default = "rg-dp-qlik-ingestion"
}

variable "hub_subscription_id" {
  type    = string
  default = ""
}

variable "hub_private_dns_rg_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_names" {
  type = map(string)
  default = {
    blob = "privatelink.blob.core.windows.net"
    dfs  = "privatelink.dfs.core.windows.net"
  }
}

variable "storage_account_name" { type = string }

variable "containers" {
  type    = list(string)
  default = ["qlik-ingestion"]
}

variable "subnet_id_private_endpoints" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
