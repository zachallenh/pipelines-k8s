# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  cloud {
    workspaces {
      name = "pipelines-k8s"
      project = "sandbox"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }

  required_version = ">= 1.1.0"
}



provider "google" {
  project = var.google_project
  region  = var.region
}