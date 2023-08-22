#
# Terraform to create a Google Cloud project for *demo* purpose.
#
# The project created with this module features:
# 1. 
# and have the following APIs enabled by default:
#

locals {
  labels = merge(
    tomap({
      "project" = "${var.name}"
      "purpose" = "demo"
    }),
    var.labels,
  )

  services = setunion(
    toset([
      "iam.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "servicenetworking.googleapis.com"
    ]),
  var.services)
}

module "google_project" {
  source = "../project"

  name       = var.name
  project_id = var.project_id
  folder_id  = var.folder_id

  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network

  labels   = local.labels
  services = local.services
}
