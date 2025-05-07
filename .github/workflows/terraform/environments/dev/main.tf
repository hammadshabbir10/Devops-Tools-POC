terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hashicorp-learn_hammad"  
    
    workspaces {
      name = "Hammad-Workspace" 
    }
  }
}

module "mysql" {
  source = "../../modules/mysql"
  
  namespace          = "movie-booking"
  mysql_root_password = var.mysql_root_password
  storage_size       = "5Gi"
}

module "microservices" {
  source = "../../modules/microservices"
  
  namespace      = "movie-booking"
  mysql_host     = module.mysql.service_name
  image_versions = var.image_versions
}

module "ingress" {
  source = "../../modules/ingress"
  
  namespace = "movie-booking"
  hostname  = "moviebooking.local"
}