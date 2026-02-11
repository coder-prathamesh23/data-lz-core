provider "azurerm" {
  features {}
}

# The module expects the caller (stack) to pass an aliased hub provider if hub resources are in a different subscription.
# If hub is in the same subscription, the stack can still pass azurerm as azurerm.hub.
