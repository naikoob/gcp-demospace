module "consumer-vpc" {
  source = "../modules/demo-vpc"

  network_name = "consumer-vpc"
  project_id   = "private-service-connect-347700"

  subnets = [
    {
      subnet_name           = "consumer-subnet-01"
      subnet_ip             = "10.1.18.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name           = "consumer-subnet-psc"
      subnet_ip             = "10.1.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    }
  ]
}

resource "google_compute_address" "psc_service_address" {
  name   = "psc-service-address"
  region = var.region

  subnetwork   = module.consumer-vpc.subnets["${var.region}/consumer-subnet-psc"].id
  address_type = "INTERNAL"
  address      = var.consumer_psc_address
}

resource "google_compute_forwarding_rule" "psc_consumer" {
  name   = "psc-consumer-forwarding-rule"
  region = var.region

  target                = google_compute_service_attachment.psc_ilb_service_attachment.id
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = module.consumer-vpc.network_id
  ip_address            = google_compute_address.psc_service_address.id
}


# firewall rule to deny access to service connect by default
resource "google_compute_firewall" "deny_psc_access" {
  name        = "deny-psc-access"
  network     = module.consumer-vpc.network_id
  description = "Deny access to private service connect address by default"
  direction   = "EGRESS"

  deny {
    protocol = "tcp"
  }
  destination_ranges = [module.consumer-vpc.subnets["${var.region}/consumer-subnet-psc"].ip_cidr_range]
  priority           = 3000
}

# service account to be granted access to private service
resource "google_service_account" "psc_access_service_account" {
  account_id   = "psc-access-sa"
  display_name = "Private Service Connect Access"
}


# firewall rule to allow access to service connect for service account
resource "google_compute_firewall" "allow_psc_access" {
  name        = "allow-psc-access"
  network     = module.consumer-vpc.network_id
  description = "Deny access to private service connect address by default"
  direction   = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_service_accounts = [google_service_account.psc_access_service_account.email]
  destination_ranges      = [module.consumer-vpc.subnets["${var.region}/consumer-subnet-psc"].ip_cidr_range]
  priority                = 1000
}

# compute instance with private access 
resource "google_compute_instance" "instance-1" {
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
    subnetwork = module.consumer-vpc.subnets["${var.region}/consumer-subnet-01"].id
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
    subnetwork = module.consumer-vpc.subnets["${var.region}/consumer-subnet-01"].id
  }
}
