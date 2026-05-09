# accounts/dev/us-east-2/vpc/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "${get_repo_root()}/modules/vpc"    # ← absolute path using terragrunt function
}

inputs = {
  vpc_name = "dev-ecommerce-vpc"
  vpc_cidr = "10.0.0.0/16"
  availability_zones   = ["us-east-2a", "us-east-2b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = true
}