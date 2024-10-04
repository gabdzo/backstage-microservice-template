# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.base_source_url}?version=5.1.1"
}

dependency "data" {
    config_path = "${dirname(find_in_parent_folders())}/terragrunt/data"

    mock_outputs = {
      az_names = [""]
    }
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
    vpc_cidr = "10.0.0.0/16"
    # azs      = slice(dependency.data.outputs.az_names, 0, 3)

    # Expose the base source URL so different versions of the module can be deployed in different environments. This will
    # be used to construct the terraform block in the child terragrunt configurations.
    base_source_url = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

    cidr = local.vpc_cidr


  # TODO: To avoid storing your DB password in the code, set it as the environment variable TF_VAR_master_password
}