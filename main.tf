module "network" {
  source             = "./modules/network"
  project_id         = var.project_id
  environment        = var.environment
  region             = var.region
  project_prefix     = var.project_prefix
  ssh_allowed_cidr   = var.ssh_allowed_cidr
}

module "database" {
  source                   = "./modules/database"
  project_id               = var.project_id
  environment              = var.environment
  region                   = var.region
  project_prefix           = var.project_prefix
  network_self_link        = module.network.vpc_self_link
  private_subnet_self_link = module.network.private_subnet_self_link
  db_password              = var.db_password
}

module "compute" {
  source                  = "./modules/compute"
  project_id              = var.project_id
  environment             = var.environment
  region                  = var.region
  zone                    = var.zone
  project_prefix          = var.project_prefix
  public_subnet_self_link = module.network.public_subnet_self_link
  startup_script          = var.startup_script
}

output "web_external_ip" { value = module.compute.external_ip }
output "db_private_ip"  { value = module.database.db_private_ip }
output "vpc_self_link"  { value = module.network.vpc_self_link }
