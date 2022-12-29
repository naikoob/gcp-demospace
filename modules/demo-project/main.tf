#
# Terraform to create a Google Cloud project for *demo* purpose.
#
# The project created with this module features:
# 1. 
# and have the following APIs enabled by default:
#

resource "google_project" "project" {
  name       = var.name
  project_id = var.project_id
  folder_id  = var.folder_id

  billing_account = var.billing_account
}

resource "google_project_service" "services" {
  for_each = var.services
  service  = each.value

  project = google_project.project.project_id

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = false
}