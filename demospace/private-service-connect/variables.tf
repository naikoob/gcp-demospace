variable "project" {
  description = "GCP project to deploy to"
  type        = string
}

variable "region" {
  description = "GCP region to deploy to"
  type        = string
}

variable "consumer_psc_address" {
  description = "IP address assigned to service attachment"
  type        = string
  default     = "10.1.20.100"
}

variable "producer_psc_subnet_cidr" {
  description = "CIDR for private service connect subnet"
  type        = string
  default     = "192.168.20.0/24"
}

variable "producer_subnet_cidr" {
  description = "CIDR for producer subnet"
  type        = string
  default     = "10.2.20.0/24"
}
