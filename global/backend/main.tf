provider "google" {
  project = "demospace-terraform"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}

resource "google_storage_bucket" "terraform-state" {
  name          = "tf-state-demospace-terraform"
  location      = "asia"
  force_destroy = true

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

