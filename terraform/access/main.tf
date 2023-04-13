# Create access policy for the web application
resource "azurerm_key_vault_access_policy" "app_policy" {
  key_vault_id = var.kv-id
  tenant_id    = var.tenant-id
  object_id    = var.web-app-principal-id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}

# Create access policy for the process running IaC
resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = var.kv-id
  tenant_id    = var.tenant-id
  object_id    = var.current-principal-id

  lifecycle {
    create_before_destroy = true
  }

  secret_permissions = var.kv-secret-permissions-full
}
