output "project_id" {
  value       = module.google_project.project_id
  description = "Project id"
}

output "labels" {
  value       = local.labels
  description = "Project labels"
}
