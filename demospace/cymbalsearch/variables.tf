variable "organization" {
  description = "Google Cloud organization"
  type        = string
}

variable "folder" {
  description = "Parent folder to deploy to"
  type        = string
  default     = "demospace"
}

variable "billing_account_name" {
  description = "Display name of billing account"
  type        = string
}

variable "region" {
  description = "GCP region to deploy to"
  type        = string
  default     = "us-central1" # 
}
