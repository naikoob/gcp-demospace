# create the vpc for producer project
module "producer-vpc" {
  source = "../modules/demo-vpc"

  network_name = "producer-vpc"
  project_id   = module.producer_project.project_id

  subnets = [
    {
      subnet_name           = "producer-subnet"
      subnet_ip             = var.producer_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name           = "private-service-connect-subnet"
      subnet_ip             = var.private_service_connect_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      purpose               = "PRIVATE_SERVICE_CONNECT"
    },
  ]
}

# create an internal load-balanced service
module "internal-load-balanced-service" {
  source = "../modules/internal-load-balanced-mig"

  name    = "simple-nginx"
  project = module.producer_project.project_id
  region  = var.region
  network = module.producer-vpc.network_id
  subnet  = module.producer-vpc.subnets["${var.region}/producer-subnet"].id
}

# allow http from private-service-connect subnet
resource "google_compute_firewall" "producer_allow_http" {
  name    = "producer-allow-http-ingress-from-psc-subnet"
  project = module.producer_project.project_id
  network = module.producer-vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [var.private_service_connect_subnet_cidr]
  target_tags   = ["http-server", "load-balanced-backend"]
}

# the service attachment
resource "google_compute_service_attachment" "nginx_service_attachment" {
  name    = "private-service"
  project = module.producer_project.project_id
  region  = var.region

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [module.producer-vpc.subnets["${var.region}/private-service-connect-subnet"].id]
  target_service        = module.internal-load-balanced-service.target_service_id
}
