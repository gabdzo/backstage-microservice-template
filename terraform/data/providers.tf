terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"  # Specify the version you need
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"  # Specify the version you need
    }
  }

  required_version = ">= 0.13"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
  load_config_file = true
  config_path      = "~/.kube/config"
}