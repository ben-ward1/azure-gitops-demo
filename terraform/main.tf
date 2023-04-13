terraform {
  required_version = ">= 0.15"
  backend "azurerm" {
    storage_account_name = "__storageAccountName__"
    access_key           = "__accessKey__"
    container_name       = "__containerName__"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

module "infra" {
  source                   = "./infra"
  sql-admin-login          = var.sql-admin-login
  sql-admin-login-password = var.sql-admin-login-password
  app-name                 = var.app-name
  az-location              = var.az-location
  app-sp-name              = var.app-sp-name
  db-server-name           = var.db-server-name
  db-name                  = var.db-name
  rg-name                  = var.rg-name
  current-ip               = chomp(data.http.myip.body)
  kv-name                  = var.kv-name
  tenant-id                = data.azurerm_client_config.current.tenant_id
}

module "access" {
  source               = "./access"
  tenant-id            = data.azurerm_client_config.current.tenant_id
  current-principal-id = data.azurerm_client_config.current.object_id
  web-app-principal-id = module.infra.web-app-principal-id
  kv-id                = module.infra.kv-id

  depends_on = [
    module.infra
  ]
}

module "data" {
  source            = "./data"
  kv-id             = module.infra.kv-id
  db-admin-logon    = var.sql-admin-login
  db-admin-password = var.sql-admin-login-password
  db-server-name    = var.db-server-name
  db-name           = var.db-name

  depends_on = [
    module.access
  ]
}
