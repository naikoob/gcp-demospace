provider "google" {
  region = var.region
  zone   = "${var.region}-a"
}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  special = false
}

data "google_organization" "org" {
  domain = var.organization
}

data "google_billing_account" "account" {
  display_name = var.billing_account_name
  open         = true
}

data "google_active_folder" "folder" {
  display_name = var.folder
  parent       = data.google_organization.org.name
}

module "project" {
  source = "../modules/demo-project"

  name       = "billinginsights"
  project_id = "billinginsights-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  billing_account = data.google_billing_account.account.id

  services = [
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com"
  ]
}

resource "google_bigquery_dataset" "dataset" {
  project       = module.project.project_id
  dataset_id    = "argolis_standard_billing"
  friendly_name = "Argolis Standard Billing"
  description   = "Argolis Standard Billing"
  location      = "asia-southeast1"
  #  default_table_expiration_ms = 3600000
}
