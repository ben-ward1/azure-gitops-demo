resource "azurerm_key_vault" "key-vault" {
  name                       = var.kv-name
  location                   = var.az-location
  resource_group_name        = var.rg-name
  tenant_id                  = var.tenant-id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Create access policy for the process running IaC
resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = var.tenant-id
  object_id    = var.current-principal-id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}

# Create access policy for the web application
resource "azurerm_key_vault_access_policy" "app_policy" {
  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = var.tenant-id
  object_id    = var.web-app-principal-id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}

resource "azurerm_key_vault_secret" "sql-db-connection-string" {
  key_vault_id = azurerm_key_vault.key-vault.id
  name         = "sqlConnectionString"
  value        = "Server=tcp:${var.db-server-name}.database.windows.net,1433;Initial Catalog=${var.db-name};Persist Security Info=False;User ID=${var.db-admin-logon};Password=${var.db-admin-password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  depends_on = [
    azurerm_key_vault.key-vault,
    azurerm_key_vault_access_policy.default_policy
  ]
}
