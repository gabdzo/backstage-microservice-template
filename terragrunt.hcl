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
