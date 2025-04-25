# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "google_compute_zones" "available" {}

data "google_container_engine_versions" "gke_version" {
  location       = var.region
  version_prefix = "1.32."
}

resource "google_container_cluster" "engineering" {
  name     = var.cluster_name
  location = data.google_compute_zones.available.names.0

  deletion_protection = false

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}