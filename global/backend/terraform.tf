terraform {
  backend "gcs" {
    bucket = "tf-state-demospace-terraform"
    prefix = "terraform/state"
  }
}
