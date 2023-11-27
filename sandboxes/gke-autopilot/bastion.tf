# bastion compute instance
resource "google_compute_instance" "bastion" {
  name         = "bastion-vm"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"
  tags         = ["ssh"]

  project = module.project.project_id

  metadata = {
    enable-oslogin = "TRUE"
  }

  # startup script
  metadata_startup_script = "sudo apt-get update"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
  network_interface {
    network    = module.demo_vpc.network_id
    subnetwork = module.demo_vpc.subnets["${var.region}/demo-subnet1"].id
  }
}
