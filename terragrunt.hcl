locals {
  common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/_common_vars.yml"))
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.common_vars.env}-${local.common_vars.project}-${local.common_vars.account_id}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tsstate"
    region         = local.common_vars.region
    encrypt        = true
    dynamodb_table = "${local.common_vars.env}-${local.common_vars.project}-${local.common_vars.account_id}-tfstate"
  }
}


# generate "versions" {
#   path      = "versions.tf"
#   if_exists = "overwrite"
#   contents  = <<EOF
#     terraform {
#       required_version = ">= 1.0.0"

#       required_providers {
#         aws = {
#           source  = "hashicorp/aws"
#           version = ">= 3.72"
#         }
#         kubernetes = {
#           source  = "hashicorp/kubernetes"
#           version = ">= 2.7.1"  # Specify the version you need
#         }
#         kubectl = {
#           source  = "gavinbunney/kubectl"
#           version = ">= 1.11.3"  # Specify the version you need
#         }
#         helm = {
#           source  = "hashicorp/helm"
#           version = ">= 2.4.1"
#         }
#       }

#       # ##  Used for end-to-end testing on project; update to suit your needs
#       # backend "s3" {
#       #   bucket = "terraform-ssp-github-actions-state"
#       #   region = "us-west-2"
#       #   key    = "e2e/fully-private-eks-cluster/terraform.tfstate"
#       # }
#     }
# EOF
# }


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "aws" {
        region = "${local.common_vars.region}"
        assume_role {
            role_arn = "arn:aws:iam::${local.common_vars.account_id}:role/deployment-role"
            external_id = "${local.common_vars.project}"
        }
    }
EOF
}
