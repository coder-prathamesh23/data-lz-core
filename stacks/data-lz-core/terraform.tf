terraform {
  required_version = ">= 1.5.0"
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
}

