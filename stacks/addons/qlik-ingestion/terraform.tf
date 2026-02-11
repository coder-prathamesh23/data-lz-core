terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# Hub alias used only if you need to data-source private DNS zones from a central subscription
provider "azurerm" {
  alias = "hub"
  features {}
  subscription_id                 = var.hub_subscription_id != "" ? var.hub_subscription_id : null
  resource_provider_registrations = "none"
}
