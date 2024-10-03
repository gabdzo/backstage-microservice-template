# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for EKS. The common variables for each environment to
# deploy VPC are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.base_source_url}?version=20.24.2"
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/terragrunt/${local.common_vars.env}/aws/backstage/core/vpc"

  mock_outputs = {
    vpc_id          = "vpc-1234567890abcdef0"
    public_subnets  = ["asdf", "asdf", "asdf"]
    private_subnets = ["asdf", "asdf", "asdf"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/_common_vars.yml"))

  # Base source URL for the Terraform AWS EKS module
  base_source_url = "tfr://registry.terraform.io/terraform-aws-modules/eks/aws"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name    = "showcase"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
  #   control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
  }

  eks_managed_node_groups = {
    example = {
      name = "default"
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   # One access entry with a policy associated
  #   role = {
  #     kubernetes_groups = ["masters"]
  #     principal_arn     = "arn:aws:iam::${local.common_vars.account_id}:role/deployment-role"
  #     policy_associations = {
  #       role = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  #   root = {
  #     kubernetes_groups = ["masters"]
  #     principal_arn     = "arn:aws:iam::${local.common_vars.account_id}:role/deployment-role"
  #     user_name         = "root"
  #     policy_associations = {
  #       role = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  #   terraform = {
  #     kubernetes_groups = ["masters"]
  #     principal_arn     = "arn:aws:iam::${local.common_vars.account_id}:role/deployment-role"
  #     user_name         = "terraform"
  #     policy_associations = {
  #       role = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }

  tags = local.common_vars.tags
}