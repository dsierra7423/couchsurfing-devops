output "db_private_ip" {
  value = google_sql_database_instance.db.private_ip_address
}