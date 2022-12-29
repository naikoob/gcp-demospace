#
# Terraform module to create load balanced MIG for *DEMO* purpose.
#
# This module creates:
# 1. (optionally) instance template to start nginx web server
# 2. A managed instance group
# 3. Simple healthcheck using serving port
# 4. Regional(internal) load balancer (forwarding rule and backend)
# 5. Firewall rules for healthchecks
#

# Default instance template if none is supplied
resource "google_compute_instance_template" "instance_template" {
  count = var.custom_instance_template ? 0 : 1

  name    = "${var.name}-instance-template"
  project = var.project

  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = var.network
    subnetwork = var.subnet
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }
  shielded_instance_config {
    enable_secure_boot = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF

    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create managed instance group
resource "google_compute_region_instance_group_manager" "mig" {
  name    = "${var.name}-mig"
  project = var.project
  region  = var.region

  version {
    instance_template = var.custom_instance_template ? var.custom_instance_template_id : google_compute_instance_template.instance_template[0].id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow http/https for healthchecks
resource "google_compute_firewall" "allow_healthcheck" {
  name    = "${var.name}-allow-healthcheck"
  project = var.project
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server", "load-balanced-backend"]
}

# create a health check
resource "google_compute_region_health_check" "healthcheck" {
  name    = "${var.name}-healthcheck"
  project = var.project
  region  = var.region

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# backend service
resource "google_compute_region_backend_service" "backend" {
  name    = "${var.name}-backend"
  project = var.project
  region  = var.region

  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.healthcheck.id]
  backend {
    group          = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

# forwarding rule to target
resource "google_compute_forwarding_rule" "target_service" {
  name    = "${var.name}-forwarding-rule"
  project = var.project
  region  = var.region

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend.id
  ports                 = ["80"]
  network               = var.network
  subnetwork            = var.subnet
}

