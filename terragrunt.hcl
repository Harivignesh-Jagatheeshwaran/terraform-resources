# terragrunt.hcl

locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "tf-statemanagement-dataplatform-${local.account.locals.environment}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.region.locals.region
    encrypt      = true
    use_lockfile = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "${local.region.locals.region}"

  default_tags {
    tags = {
      Environment = "${local.account.locals.environment}"
      Team        = "dataplatform"
      ManagedBy   = "terraform"
    }
  }
}
EOF
}