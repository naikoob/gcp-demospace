terraform {
  backend "gcs" {
    bucket = "tf-state-demospace"
    prefix = "terraform/backend/state/"
  }
}
