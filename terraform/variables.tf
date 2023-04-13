
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
