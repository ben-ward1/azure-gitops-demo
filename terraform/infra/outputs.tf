output "web-app-principal-id" {
  description = "The principal id associated with the app service's system assigned identity"
  value       = azurerm_windows_web_app.dev.identity[0].principal_id
}

output "kv-id" {
  description = "The id of the key vault"
  value       = azurerm_key_vault.key-vault.id
}
