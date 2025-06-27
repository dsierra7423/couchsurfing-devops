resource "google_project_service" "cloud_sql" {
  project            = var.project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service_identity" "cloud_sql_sa" {
  provider   = google-beta
  project    = var.project_id
  service    = "sqladmin.googleapis.com"
  depends_on = [google_project_service.cloud_sql]
}

locals { cloud_sql_sa_email = google_project_service_identity.cloud_sql_sa.email }

resource "google_compute_subnetwork_iam_member" "sa_network_user" {
  subnetwork = var.private_subnet_self_link
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${local.cloud_sql_sa_email}"
}

resource "google_compute_global_address" "private_range" {
  name          = "${var.project_prefix}-${var.environment}-db-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_self_link
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = var.network_self_link
  service                 = "services/servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_range.name]
}

resource "google_sql_database_instance" "db" {
  name                = "${var.project_prefix}-${var.environment}-db"
  region              = var.region
  database_version    = "POSTGRES_14"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }
  }

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_compute_subnetwork_iam_member.sa_network_user
  ]
}

resource "google_sql_database" "app" {
  name     = "app"
  instance = google_sql_database_instance.db.name
}

resource "google_sql_user" "app" {
  name        = "app_user"
  instance    = google_sql_database_instance.db.name
  password_wo = var.db_password
}
