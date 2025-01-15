# Shared VPC host project
module "host_project" {
  source = "../modules/demo-project"

  name       = "vpc-host"
  project_id = "vpc-host-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  labels = local.labels

  billing_account = data.google_billing_account.account.id
}

module "shared_vpc" {
  source = "../modules/demo-vpc"

  network_name = "producer-vpc"
  project_id   = module.host_project.project_id

  shared_vpc_host = true

  subnets = [
    {
      subnet_name      = "main-subnet"
      subnet_ip        = var.main_subnet_cidr
      subnet_region    = var.region
      subnet_flow_logs = "true"
    }
  ]

  shared_vpc_subnets = [
    {
      subnet_name      = "service-subnet"
      subnet_ip        = var.service_project_subnet_cidr
      subnet_region    = var.region
      subnet_flow_logs = "true"
    }
  ]
}
