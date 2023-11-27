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

  name       = "gke-autopilot"
  project_id = "gke-autopilot-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  billing_account = data.google_billing_account.account.id

  services = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "binaryauthorization.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com" # this is for demo purpose
  ]
}

module "demo_vpc" {
  source = "../modules/demo-vpc"

  network_name = "demo-vpc"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "demo-subnet1"
      subnet_ip             = "10.100.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
  ]
}
