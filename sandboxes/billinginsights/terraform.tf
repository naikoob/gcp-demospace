terraform {
  backend "gcs" {
    bucket = "tf-state-sandboxes"
    prefix = "terraform/state/billinginsights"
  }
}

