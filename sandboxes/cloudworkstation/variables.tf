variable "organization" {
  description = "Google Cloud organization"
  type        = string
}

variable "folder" {
  description = "Parent folder to deploy to"
  type        = string
  default     = "sandboxes"
}

variable "billing_account_name" {
  description = "Display name of billing account"
  type        = string
}

variable "region" {
  description = "GCP region to deploy to"
  type        = string
  default     = "us-west1"
}
