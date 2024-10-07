# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for ECR. The common variables for each environment to
# deploy VPC are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.base_source_url}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/_common_vars.yml"))
  # Base source URL for the Terraform AWS ECR module
  base_source_url = "${dirname(find_in_parent_folders())}/terraform/data"
}

dependency "addons" {
  config_path = "${dirname(find_in_parent_folders())}/terragrunt/${local.common_vars.env}/aws/backstage/addons/eks_addons"

  skip_outputs = true
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = "showcase"

  tags = local.common_vars.tags
}