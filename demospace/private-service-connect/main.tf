provider "google" {
  region = var.region
  zone   = "${var.region}-a"
}
