
variable "rg-name" {
  type        = string
  description = "Name of the resource group"
}

variable "az-location" {
  type        = string
  description = "Azure region for this system's resources"
}

variable "app-sp-name" {
  type        = string
  description = "The service plan name for the web app"
}

variable "app-name" {
  type        = string
  description = "The name for the web app"
}

variable "db-server-name" {
  type        = string
  description = "Name of the sql server"
}


variable "db-name" {
  type        = string
  description = "Name of the sql db"
}

variable "sql-admin-login" {
  type        = string
  description = "The login name for the sql server admin"
}

variable "sql-admin-login-password" {
  type        = string
  description = "The password for the sql server admin"
}

variable "current-ip" {
  type        = string
  description = "ip address for the current execution environment"
}
