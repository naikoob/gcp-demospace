variable "name" {
  description = "Managed instance group name"
}

variable "project" {
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  description = "The region where resources will be deployed"
}

variable "network" {
  description = "The network (id) where resources will be deployed"
}

variable "subnet" {
  type        = string
  description = "The subnet (id) where the load balanced IP resides"
}

variable "custom_instance_template" {
  type        = bool
  description = "true if an instance template is supplied via instance_template_id variable, false if otherwise"
  default     = false
}

variable "custom_instance_template_id" {
  type        = string
  description = "Custom instance template id, must be supplied if custom_instance_template is true"
  default     = "dummy-value"
}