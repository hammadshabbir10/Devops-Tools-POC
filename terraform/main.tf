


terraform {
  required_version = ">= 1.0.0"
  
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hashicorp-learn_hammad"
    workspaces {
      name = "Devops_WorkflowSpace"
    }
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

variable "KUBE_CONFIG" {
  description = "Base64 encoded kubeconfig"
  type        = string
  sensitive   = true
}

locals {
  kubeconfig = yamldecode(base64decode(var.KUBE_CONFIG))
  cluster    = local.kubeconfig.clusters[0].cluster
  user       = local.kubeconfig.users[0].user
}

provider "kubernetes" {
  host = "https://kubernetes.docker.internal:6443"
  
  # Use direct certificate authentication
  cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.user["client-certificate-data"])
  client_key             = base64decode(local.user["client-key-data"])
}

provider "helm" {
  kubernetes {
    host = "https://kubernetes.docker.internal:6443"
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.user["client-certificate-data"])
    client_key             = base64decode(local.user["client-key-data"])
  }
}