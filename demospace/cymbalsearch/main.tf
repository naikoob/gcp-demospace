locals {
  labels = {
    "demo" = "cloud-armor-shared-vpc"
  }
}

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
