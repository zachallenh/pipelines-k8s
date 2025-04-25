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

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}

resource "google_container_node_pool" "engineering_preemptible_nodes" {
  name     = "${var.cluster_name}-node-pool"
  cluster  = google_container_cluster.engineering.name
  location = data.google_compute_zones.available.names.0

  version    = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    kubelet_config {
      cpu_cfs_quota = false
      cpu_cfs_quota_period = ""
      cpu_manager_policy = ""
      pod_pids_limit = 0
    }

    # reservation_affinity {
    #   consume_reservation_type = "NO_RESERVATION"
    # }
  }
}