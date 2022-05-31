module "producer-vpc" {
  source = "../modules/demo-vpc"

  network_name = "producer-vpc"
  project_id   = var.project

  subnets = [
    {
      subnet_name           = "producer-subnet-01"
      subnet_ip             = var.producer_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name           = "producer-subnet-psc"
      subnet_ip             = var.producer_psc_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      purpose               = "PRIVATE_SERVICE_CONNECT"
    },
  ]
}

resource "google_compute_firewall" "producer_allow_http" {
  name    = "producer-allow-http-ingress-from-iap"
  network = module.producer-vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [var.producer_psc_subnet_cidr, "130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server", "load-balanced-backend"]
}

resource "google_compute_service_attachment" "psc_ilb_service_attachment" {
  name   = "my-psc-ilb"
  region = var.region

  //  domain_names          = ["psc-demo.private."]
  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [module.producer-vpc.subnets["${var.region}/producer-subnet-psc"].id]
  target_service        = google_compute_forwarding_rule.nginx_target_service.id
}

# forwarding rule to target
resource "google_compute_forwarding_rule" "nginx_target_service" {
  name   = "producer-forwarding-rule"
  region = var.region

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.nginx_backend.id
  ports                 = ["80"]
  network               = module.producer-vpc.network_id
  subnetwork            = module.producer-vpc.subnets["${var.region}/producer-subnet-01"].id
}

# backend service
resource "google_compute_region_backend_service" "nginx_backend" {
  name   = "nginx-backend"
  region = var.region

  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.nginx_healthcheck.id]
  backend {
    group          = google_compute_region_instance_group_manager.nginx_mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

# instance template
resource "google_compute_instance_template" "nginx_instance_template" {
  name         = "nginx-instance-template"
  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = module.producer-vpc.network_id
    subnetwork = module.producer-vpc.subnets["${var.region}/producer-subnet-01"].id
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

# create a health check
resource "google_compute_region_health_check" "nginx_healthcheck" {
  name   = "nginx-hc"
  region = var.region
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# create managed instance group
resource "google_compute_region_instance_group_manager" "nginx_mig" {
  name   = "nginx-mig1"
  region = var.region
  version {
    instance_template = google_compute_instance_template.nginx_instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
