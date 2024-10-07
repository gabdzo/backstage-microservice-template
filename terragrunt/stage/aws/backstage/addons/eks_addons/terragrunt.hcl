# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This file includes common configurations and modules for the Terragrunt setup.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root configuration for provider and backend settings -> tf.state
include "root" {
  path = find_in_parent_folders()
}

# Include the common EKS addons configuration
include "addons" {
  path = "${dirname(find_in_parent_folders())}/terragrunt/_common/eks_addons.hcl"
}

# Include the common configuration, which contains shared variables and settings used across multiple modules
include "common" {
  path = "${dirname(find_in_parent_folders())}/terragrunt/_common/_common.hcl"
}