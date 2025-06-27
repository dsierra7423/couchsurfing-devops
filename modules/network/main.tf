locals {
  vpc_name            = "${var.project_prefix}-${var.environment}-vpc"
  public_subnet_name  = "${var.project_prefix}-${var.environment}-public"
  private_subnet_name = "${var.project_prefix}-${var.environment}-private"
}

resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = local.public_subnet_name
  ip_cidr_range = "10.10.10.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "private" {
  name                     = local.private_subnet_name
  ip_cidr_range            = "10.10.20.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_router" "nat_router" {
  name    = "${var.project_prefix}-${var.environment}-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_prefix}-${var.environment}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "ingress_ssh" {
  name    = "${var.project_prefix}-${var.environment}-ingress-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.ssh_allowed_cidr
  target_tags   = ["web-tier"]
}

resource "google_compute_firewall" "ingress_web" {
  name    = "${var.project_prefix}-${var.environment}-ingress-web"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-tier"]
}

