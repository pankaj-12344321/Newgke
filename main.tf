##requirments:
## A GKE cluster resides in VPC and having 3 nodes 

resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = var.networkname
  auto_create_subnetworks = false
  mtu                     = var.mtu
}

resource "google_compute_subnetwork" "simplesubnet" {
  name          = var.subname
  ip_cidr_range = var.cidrsub
  region        = var.location
  network       = google_compute_network.vpc_network.id
  
}




resource "google_container_cluster" "primary" {
  name     = var.gkename
  location = var.location
  network = google_compute_network.vpc_network.name
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = true
    master_ipv4_cidr_block = var.cidr
  }

  # Required prior to GKE 1.36.4-gke.1469000 to use separately managed node pools
  # remove_default_node_pool = true
  # initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.nodepool
  cluster    = google_container_cluster.primary.id
  node_count = var.nodenum

  node_config {
    preemptible  = true
    machine_type = var.instancetype

  }
}