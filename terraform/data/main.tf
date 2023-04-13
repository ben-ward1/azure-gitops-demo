resource "azurerm_key_vault_secret" "sql-db-connection-string" {
  key_vault_id = var.kv-id
  name         = "sqlConnectionString"
  value        = "Server=tcp:${var.db-server-name}.database.windows.net,1433;Initial Catalog=${var.db-name};Persist Security Info=False;User ID=${var.db-admin-logon};Password=${var.db-admin-password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}
