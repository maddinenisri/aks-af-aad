terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = ">= 2.26"
    azuread = ">= 1.4.0"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}
