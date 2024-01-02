output "project_id" {
  value = module.cymbal_search_project.project_id
}

output "gcs_bucket" {
  value = resource.google_storage_bucket.upload_bucket.name
}
