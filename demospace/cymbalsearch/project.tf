# Cymbal Search project
module "cymbal_search_project" {
  source = "../modules/demo-project"

  name       = "cymbal-search"
  project_id = "cymbal-search-${random_string.suffix.result}"
  folder_id  = data.google_active_folder.folder.name

  billing_account = data.google_billing_account.account.id

  labels = local.labels

  services = [
    "aiplatform.googleapis.com",        # vertex ai
    "artifactregistry.googleapis.com",  # registry - used by pipelines
    "compute.googleapis.com",           # compute - used by colab ent
    "dataflow.googleapis.com",          # dataflow - used by pipelines
    "dataform.googleapis.com",          # dataform - used by colab ent
    "discoveryengine.googleapis.com",   # discovery engine
    "notebooks.googleapis.com",         # notebooks
    "storage-component.googleapis.com", # cloud storage
    "visionai.googleapis.com"           # vision ai - used by model garden
  ]
}

resource "google_storage_bucket" "upload_bucket" {
  project       = module.cymbal_search_project.project_id
  name          = module.cymbal_search_project.project_id
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_project_organization_policy" "allow_unauthenticated" {
  project    = module.cymbal_search_project.project_id
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  }
}
