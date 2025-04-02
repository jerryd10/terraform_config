terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "terraform-visal"
  region  = "australia-southeast1"
  zone    = "australia-southeast1-b"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_subnetwork" "subnet_1" {
  name = "terraform-network-subnet1"
  region = "australia-southeast1"
  network = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.1.0/24"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_2" {
  name = "terraform-network-subnet2"
  region = "australia-southeast1"
  network = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.2.0/24"
  private_ip_google_access = true
}

# subnet_1 -X-> subnet_2
# but subnet_1 <--- subnet_2 (no fw for this, so allow)

resource "google_compute_firewall" "block-subnet_1-subnet_2" {
  name = "block-subnet1-subnet2"
  network = google_compute_network.vpc_network.self_link

  deny {
    protocol = "tcp" # encaps IP so no network comms
    ports = ["0", "22", "80", "443"]
  }

  source_ranges = ["10.0.1.0/24"] # subnet_1

  destination_ranges = ["10.0.2.0/24"] # subnet_2
}