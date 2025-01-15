terraform {
  backend "gcs" {
    bucket = "tf-state-demospace"
    prefix = "terraform/state/cloud-armour-shared-vpc"
  }
}
