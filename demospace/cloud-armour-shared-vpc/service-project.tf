# Shared VPC service project
module "service_project" {
  source = "../modules/demo-project"

  name       = "service-project"
  project_id = "service-project-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  billing_account = data.google_billing_account.account.id

  labels = local.labels

  services = [
    "vpcaccess.googleapis.com" # enable shared vpc access
  ]
}

