terraform {
   backend "remote" { 
    organization = "hashicorp-learn_hammad"
    workspaces {      
      name = "Devops-WorkflowSpace"
    }
  }


  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.2.0"
}


provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}



# MySQL Module
module "mysql" {
  source = "../../modules/mysql"
  
  namespace          = "movie-booking"
  mysql_root_password = var.mysql_root_password
  storage_size       = "5Gi"
}

# Microservices Module
module "microservices" {
  source = "../../modules/microservices"
  
  namespace      = "movie-booking"
  mysql_host     = module.mysql.service_name
  image_versions = var.image_versions
}

# Ingress Module
module "ingress" {
  source = "../../modules/ingress"
  
  namespace = "movie-booking"
  hostname  = "moviebooking.local"
}