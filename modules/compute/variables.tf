variable "project_id"              { type = string }
variable "project_prefix"          { type = string }
variable "environment"             { type = string }
variable "region"                  { type = string }
variable "zone"                    { type = string }
variable "public_subnet_self_link" { type = string }
variable "startup_script" {
  type    = string
  default = "./startup.sh"
}