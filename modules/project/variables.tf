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

variable "auto_create_network" {
  description = "Create default network if true (not recommended)"
  default     = false
}

variable "labels" {
  description = "labels for the project"
  type        = map(string)
  default = {
  }
}

variable "services" {
  description = "Services to be enabled for the project"
  type        = set(string)
  default     = ["iam.googleapis.com", "compute.googleapis.com", "servicenetworking.googleapis.com"]
}
