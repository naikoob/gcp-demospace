terraform {
  backend "gcs" {
    bucket = "tf-state-demospace"
    prefix = "terraform/state/private-service-connect"
  }
}
