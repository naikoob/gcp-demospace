#
# Terraform to create a Google Cloud project.
#
# The project created with this module features:
# 1. 
# and have the following APIs enabled by default:
#

resource "google_project" "project" {
  # required
  name       = var.name
  project_id = var.project_id

  # optional
  folder_id = var.folder_id
  labels    = var.labels

  billing_account = var.billing_account

  auto_create_network = var.auto_create_network
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
