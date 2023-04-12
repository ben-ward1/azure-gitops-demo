variable "az-location" {
  type = string
}

variable "rg-name" {
  type = string
}

variable "tenant-id" {
  type = string
}

variable "current-principal-id" {
  type = string
}

variable "web-app-principal-id" {
  type = string
}

variable "db-server-name" {
  type = string
}

variable "db-name" {
  type = string
}

variable "db-admin-logon" {
  type = string
}

variable "db-admin-password" {
  type = string
}

variable "kv-name" {
  type = string
}

variable "kv-secret-permissions-full" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
