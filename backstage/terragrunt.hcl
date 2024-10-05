locals {
  # common_vars = yamldecode(file(find_in_parent_folders("common.yaml")))
  common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/common.yaml"))
  # common_vars = yamldecode(file(find_in_parent_folders("env_vars.yaml")))


}

terraform {
  extra_arguments "aws_profile" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint"
    ]

    env_vars = {
      AWS_PROFILE = "${local.common_vars.aws_profile}"
    }
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    profile        = local.common_vars.aws_profile
    bucket         = "backstage-${local.common_vars.env}-${local.common_vars.account_id}-tfstate"
    dynamodb_table = "backstage-${local.common_vars.env}-${local.common_vars.account_id}-dynamodb"

    key                 = "${path_relative_to_include()}/terraform.tfstate"
    region              = local.common_vars.region
    encrypt             = true
    s3_bucket_tags      = local.common_vars.tags
    dynamodb_table_tags = local.common_vars.tags
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
        provider "aws" {
            region = "${local.common_vars.region}"
            profile = "${local.common_vars.aws_profile}"
        }
        EOF
}
