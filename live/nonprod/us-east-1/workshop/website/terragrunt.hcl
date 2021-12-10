locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract desired variables
  env = local.environment_vars.locals.environment
}

terraform {
  source  = "../../../../../modules/static-website///"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_name = join("-", [local.env, "zrp", "diego"])
  origin_id = join("-", [local.env, "zrp", "diego"])
}

