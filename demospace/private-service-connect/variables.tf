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
  default     = "us-west1"
}

variable "consumer_subnet_cidr" {
  description = "CIDR for consumer subnet"
  type        = string
  default     = "10.1.10.0/24"
}

variable "consumer_psc_subnet_cidr" {
  description = "CIDR for private service connect consumer subnet"
  type        = string
  default     = "10.1.20.0/24"
}

variable "consumer_psc_address" {
  description = "IP address assigned to service attachment"
  type        = string
  default     = "10.1.20.100"
}

variable "private_service_connect_subnet_cidr" {
  description = "CIDR for private service connect subnet"
  type        = string
  default     = "192.168.10.0/24"
}

variable "producer_subnet_cidr" {
  description = "CIDR for producer subnet"
  type        = string
  default     = "10.2.10.0/24"
}
