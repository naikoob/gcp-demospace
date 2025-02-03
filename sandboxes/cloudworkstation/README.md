# Google Cloud Workstation

## tl;dr

Creates a project, VPC, and other dependent resources, and an externally accessible Cloud Workstation.

## Resources created

- Google Cloud project
- VPC
  - custom subnet
  - NAT
  - firewall rules
- Cloud Workstation cluster
- Cloud Workstation config
- Cloud Workstation instance

## Inputs

The following variables are defined

| variable             | type and description                                    | default     |
| -------------------- | ------------------------------------------------------- | ----------- |
| organzation          | Google cloud organization name as a string              | none        |
| folder               | Folder under which the project will be created (string) | sandboxes   |
| billing_account_name | display name of the billing account (string)            | none        |
| region               | GCP region to deploy on (string)                        | us-central1 |

## [TODO]

Parameterize machine-type, pd size, etc.
