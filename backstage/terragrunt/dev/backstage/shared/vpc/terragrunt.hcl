include "root" {
    path = find_in_parent_folders()
}

include "module" {
    path = "${dirname(find_in_parent_folders())}/terragrunt/_common/modules/vpc.hcl"
}

include "module" {
    path = "${dirname(find_in_parent_folders())}/terragrunt/_common/_common.hcl"
}
