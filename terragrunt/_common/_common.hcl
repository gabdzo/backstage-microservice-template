locals {
    common_vars = yamldecode(file("${dirname(find_in_parent_folders())}/terragrunt/_common/_common_vars.yml"))
    
    module = "${basename(get_original_terragrunt_dir())}"
    name = "${local.common_vars.project}-${local.common_vars.env}-${local.module}"

}

inputs = {
    name = local.name
}