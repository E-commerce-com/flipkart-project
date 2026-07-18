provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}


# Enable Required APIs

resource "google_project_service" "container_api" {
  project = var.project
  service = "container.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project = var.project
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project = var.project
  service = "iam.googleapis.com"

  disable_on_destroy = false
}


# VPC Network

resource "google_compute_network" "custom_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}


# Subnet

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnetwork"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.custom_network.id
}


# Internal Firewall

resource "google_compute_firewall" "allow_internal" {

  name    = "internal-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.10.0.0/16"
  ]
}


# External Firewall

resource "google_compute_firewall" "allow_external" {

  name    = "external-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "3389"
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}


# GKE Firewall

resource "google_compute_firewall" "allow_gke" {

  name    = "gke-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "tcp"

    ports = [
      "443",
      "10250",
      "15017"
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}


# GKE Cluster

resource "google_container_cluster" "primary" {

  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api
  ]

  name     = "terraform-gke-cluster"

  project  = var.project

  location = var.zone

  network = google_compute_network.custom_network.id

  subnetwork = google_compute_subnetwork.custom_subnet.id


  min_master_version = var.k8s_version


  deletion_protection = false


  remove_default_node_pool = true

  initial_node_count = 1
}



# Node Pool

resource "google_container_node_pool" "primary_nodes" {

  depends_on = [
    google_container_cluster.primary
  ]


  name = "my-node-pool"


  project = var.project


  cluster = google_container_cluster.primary.name


  location = var.zone


  node_count = 1



  node_config {

    machine_type = "e2-medium"

    disk_size_gb = 15

    disk_type = "pd-standard"

    image_type = "UBUNTU_CONTAINERD"


    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

  }

}
