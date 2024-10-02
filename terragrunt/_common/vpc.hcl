# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for VPC. The common variables for each environment to
# deploy VPC are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.base_source_url}?version=5.1.1"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/_common_vars.yml"))

  # Base network config
  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.0.0/20",  # AZ1
    "10.0.16.0/20", # AZ2
    "10.0.32.0/20"  # AZ3
  ]

  private_subnets = [
    "10.0.48.0/20", # AZ1
    "10.0.64.0/20", # AZ2
    "10.0.80.0/20"  # AZ3
  ]
  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  # Base source URL for the Terraform AWS VPC module
  base_source_url = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cidr            = local.vpc_cidr
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  azs             = local.azs

  # NAT configuration
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = true

  # DNS configuration
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Disable ClassicLink (legacy feature), might be removed?
  enable_classiclink             = false
  enable_classiclink_dns_support = false

  tags = local.common_vars.tags
}