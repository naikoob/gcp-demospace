provider "google" {
  project = "terraform-backend-demospace"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}

resource "google_storage_bucket" "terraform-state-demospace" {
  name          = "tf-state-demospace"
  location      = "asia"
  force_destroy = true

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "terraform-state-sandboxes" {
  name          = "tf-state-sandboxes"
  location      = "asia"
  force_destroy = true

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}
