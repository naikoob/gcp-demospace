output "target_service_id" {
  value       = google_compute_forwarding_rule.target_service.id
  description = "The ID of the target service being created"
}
