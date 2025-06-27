locals { instance_name = "${var.project_prefix}-${var.environment}-vm" }

resource "google_compute_instance" "web" {
  name         = local.instance_name
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork   = var.public_subnet_self_link
    access_config {}
  }

  tags = ["web-tier"]

  metadata_startup_script = var.startup_script
}