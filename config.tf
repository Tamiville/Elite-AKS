terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
  required_version = ">= 0.13"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}

  subscription_id = "60313366-264b-451c-96a9-b264760c42e5"
  tenant_id       = "4df27d8c-7680-444b-8aec-522f96e17501"
  client_id       = "a4c37805-48e6-4d6b-b54b-1d272a17b763"
  client_secret   = "Poy8Q~7zD~IQRIaczTjicJq2k~zRwCOwXSwPedm."
}

provider "kubernetes" {
  alias       = "kubernetes"
  config_path = "./azurecredentials"
}