module "consumer-vpc" {
  source = "../modules/demo-vpc"

  network_name = "consumer-vpc"
  project_id   = module.consumer_project.project_id

  subnets = [
    {
      subnet_name           = "consumer-subnet"
      subnet_ip             = var.consumer_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name           = "privileged-services-subnet"
      subnet_ip             = var.consumer_psc_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    }
  ]
}

resource "google_compute_address" "psc_service_address" {
  name    = "psc-service-address"
  region  = var.region
  project = module.consumer_project.project_id

  subnetwork   = module.consumer-vpc.subnets["${var.region}/privileged-services-subnet"].id
  address_type = "INTERNAL"
  address      = var.consumer_psc_address
}

resource "google_compute_forwarding_rule" "psc_consumer" {
  name    = "psc-consumer-forwarding-rule"
  region  = var.region
  project = module.consumer_project.project_id

  target                = google_compute_service_attachment.nginx_service_attachment.id
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = module.consumer-vpc.network_id
  ip_address            = google_compute_address.psc_service_address.id
}

# service account to be granted access to private service
resource "google_service_account" "psc_access_service_account" {
  account_id   = "psc-access-sa"
  display_name = "Private Service Connect Access"

  project = module.consumer_project.project_id
}

# firewall rule to deny access to private service connect by default
resource "google_compute_firewall" "deny_psc_access" {
  name        = "deny-psc-access"
  network     = module.consumer-vpc.network_id
  description = "Deny access to private service connect address by default"
  direction   = "EGRESS"
  project     = module.consumer_project.project_id

  deny {
    protocol = "tcp"
  }
  destination_ranges = [module.consumer-vpc.subnets["${var.region}/privileged-services-subnet"].ip_cidr_range]
  priority           = 3000
}

# firewall rule to allow access to service connect for service account
resource "google_compute_firewall" "allow_psc_access" {
  project     = module.consumer_project.project_id
  name        = "allow-psc-access"
  network     = module.consumer-vpc.network_id
  description = "Deny access to private service connect address by default"
  direction   = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_service_accounts = [google_service_account.psc_access_service_account.email]
  destination_ranges      = [var.consumer_psc_address]
  priority                = 1000
}

# compute instance with private access 
resource "google_compute_instance" "instance-1" {
  project      = module.consumer_project.project_id
  name         = "psc-access-vm"
  machine_type = "f1-micro"
  zone         = "${var.region}-a"
  tags         = ["ssh"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  # startup script
  metadata_startup_script = "sudo apt-get update"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  network_interface {
    network    = module.consumer-vpc.network_id
    subnetwork = module.consumer-vpc.subnets["${var.region}/consumer-subnet"].id
  }
  # target service account with access to PSC resources
  service_account {
    email  = google_service_account.psc_access_service_account.email
    scopes = ["cloud-platform"]
  }
}

# compute instance without private access 
resource "google_compute_instance" "instance-2" {
  name         = "test-vm"
  machine_type = "f1-micro"
  zone         = "${var.region}-a"
  tags         = ["ssh"]

  project = module.consumer_project.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }

  # startup script
  metadata_startup_script = "sudo apt-get update"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  network_interface {
    network    = module.consumer-vpc.network_id
    subnetwork = module.consumer-vpc.subnets["${var.region}/consumer-subnet"].id
  }
}
