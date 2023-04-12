terraform {
  required_version = ">= 0.15"
  backend "azurerm" {
    storage_account_name = var.storage-account-name
    container_name       = var.storage-container-name
    key                  = "terraform.tfstate"
    access_key           = var.storage-account-access-key
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "dev" {
  name     = var.rg-name
  location = var.az-location
}

resource "azurerm_service_plan" "dev" {
  name                = var.app-sp-name
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  os_type             = "Windows"
  sku_name            = "F1"
}

resource "azurerm_windows_web_app" "dev" {
  name                = var.app-name
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  service_plan_id     = azurerm_service_plan.dev.id

  site_config {
    always_on = false
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v7.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_server" "db-server" {
  name                         = var.db-server-name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.az-location
  version                      = "12.0"
  administrator_login          = var.sql-admin-login
  administrator_login_password = var.sql-admin-login-password
}

resource "azurerm_mssql_database" "db" {
  name      = "sample-db"
  server_id = azurerm_mssql_server.db-server.id

  depends_on = [
    azurerm_mssql_server.db-server
  ]
}

# Create SQL Server firewall rule for Azure resouces access
resource "azurerm_sql_firewall_rule" "azureservicefirewall" {
  name                = "allow-azure-service"
  resource_group_name = azurerm_resource_group.dev.name
  server_name         = azurerm_mssql_server.db-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_key_vault" "key-vault" {
  name                       = "sample-key-vault"
  location                   = var.az-location
  resource_group_name        = azurerm_resource_group.dev.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Create access policy for the process running IaC
resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}


# Create access policy for the web application
resource "azurerm_key_vault_access_policy" "app_policy" {
  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_web_app.dev.identity[0].principal_id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}

resource "azurerm_key_vault_secret" "sql-db-connection-string" {
  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "MLxBSqlConnectionString"
  value        = "Server=tcp:${azurerm_mssql_server.db-server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${azurerm_mssql_server.db-server.administrator_login};Password=${azurerm_mssql_server.db-server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy
  ]
}
