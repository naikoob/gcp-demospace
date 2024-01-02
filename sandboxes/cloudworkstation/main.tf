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

  name       = "cloudworkstation"
  project_id = "cloudworkstation-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  billing_account = data.google_billing_account.account.id

  services = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "cloudaicompanion.googleapis.com", # for duet ai 
    "servicenetworking.googleapis.com",
    "workstations.googleapis.com"
  ]
}

module "dev_vpc" {
  source = "../modules/demo-vpc"

  network_name = "dev-vpc"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "dev-subnet"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
  ]
}

resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  project                = module.project.project_id
  workstation_cluster_id = "workstation-cluster-private"
  network                = module.dev_vpc.network_id
  subnetwork             = module.dev_vpc.subnets_ids[0]
  location               = var.region

  # private_cluster_config {
  #   enable_private_endpoint = true
  # }
}
