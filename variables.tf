variable "project_id"      { type = string }
variable "environment"     { type = string }
variable "region" {
  type      = string
  default = "us-central1"
}
variable "zone" {
  type      = string
  default = "us-central1-a"
}
variable "project_prefix" {
  type      = string
  default = "web"
}
variable "db_password" { 
  type = string 
  sensitive = true 
}
variable "startup_script"  { 
  type = string 
  default = "" 
}
variable "ssh_allowed_cidr" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
