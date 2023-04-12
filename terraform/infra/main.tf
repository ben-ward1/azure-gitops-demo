resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.az-location
}

resource "azurerm_service_plan" "dev" {
  name                = var.app-sp-name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "F1"
}

resource "azurerm_windows_web_app" "dev" {
  name                = var.app-name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
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
  name      = var.db-name
  server_id = azurerm_mssql_server.db-server.id

  depends_on = [
    azurerm_mssql_server.db-server
  ]
}

# Create SQL Server firewall rule for Azure resouces access
resource "azurerm_mssql_firewall_rule" "azureservicefirewall" {
  name             = "allow-azure-service"
  server_id        = azurerm_mssql_server.db-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Create SQL Server firewall rule for Azure resouces access
resource "azurerm_mssql_firewall_rule" "currentip" {
  name             = "allow-azure-service"
  server_id        = azurerm_mssql_server.db-server.id
  start_ip_address = var.current-ip
  end_ip_address   = var.current-ip
}
