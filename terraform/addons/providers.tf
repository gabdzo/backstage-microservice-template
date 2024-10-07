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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  required_version = ">= 0.13"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # config_context = "my-context"
}

provider "kubectl" {
  load_config_file = true
  config_path      = "~/.kube/config"
  # host                   = var.eks_cluster_endpoint
  # cluster_ca_certificate = base64decode(var.eks_cluster_ca)
  # token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}