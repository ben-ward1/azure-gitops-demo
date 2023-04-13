terraform {
  required_version = ">= 0.15"
  backend "azurerm" {
    storage_account_name = "__storageAccountName__"
    container_name       = "__containerName__"
    access_key           = "__storageKey__"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "infra" {
  source      = "./infra"
  rg-name     = var.rg-name
  az-location = var.az-location
  app-sp-name = var.app-sp-name
  app-name    = var.app-name
}
