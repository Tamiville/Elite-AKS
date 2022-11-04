# Create a resource group
resource "azurerm_resource_group" "eliteacr" {
  name     = local.azurecontainerrgistry
  location = local.buildregion
}
resource "random_string" "random" {
  length           = 5
  special          = false
  lower            = true
  upper            = "false"
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_container_registry" "eliteacr" {
  name                = "eliteclusterdemoapp${random_string.random.result}"
  resource_group_name = local.azurecontainerrgistry
  location            = local.buildregion
  sku                 = "Standard"
  admin_enabled       = false
}