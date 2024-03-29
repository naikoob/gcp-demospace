variable "name" {
  description = "The name of the project"
}

variable "project_id" {
  description = "The id of the project"
}

variable "folder_id" {
  description = "Folder to hold the project"
}

variable "billing_account" {
  description = "Billing account for the project"
}

variable "labels" {
  description = "labels for the project"
  type        = map(string)
  default = {
  }
}

variable "auto_create_network" {
  description = "Automatically creates default network when true (not recommended)"
  default     = false
}

variable "services" {
  description = "Services to be enabled for the project"
  type        = set(string)
  default     = []
}
