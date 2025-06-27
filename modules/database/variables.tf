variable "project_id"                { type = string }
variable "project_prefix"            { type = string }
variable "environment"               { type = string }
variable "region"                    { type = string }
variable "network_self_link"         { type = string }
variable "private_subnet_self_link"  { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}