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
  source = "${local.base_source_url}?ref=v0.7.0"
}

dependency "sg" {
  config_path = "../sg"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
  base_source_url = "tfr://registry.terraform.io/terraform-aws-modules/alb/aws?version=8.7.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

    name = local.app_config.locals.app_name

    load_balancer_type = "application"

    vpc_id = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.subnet_ids
    security_groups = dependency.sg.outputs.security_group_id

    internal =  true
    enable_cross_zone_load_balancing = true

    target_groups = [
        {
            name_prefix = "alb-prefix"
            backend_protocol = "HTTP"
            backend_port = 7007
            target_type = "ip"
            health_check = {
                enabled = true
                interval = 30
                path = "/api/healthcheck"
                port = "traffic-port"
                healthy_threshold = 3
                unhealthy_threshold = 3
                timeout = 6
                protocol = "HTTP"
                matcher = "200-399"
            }
        }
    ]

    https_listeners = [
        {
            port = 443
            protocol =  "HTTPS"
            certificate_arn = dependency.acm.outputs.arn
            target_groups_index = 0
        }
    ]

    http_tcp_listeners = [
        {
            port = 80
            protocol = "HTTP"
            target_group_index = 0
        }
    ]

    tags = local.env_config.locals.tags
  # TODO: To avoid storing your DB password in the code, set it as the environment variable TF_VAR_master_password
}