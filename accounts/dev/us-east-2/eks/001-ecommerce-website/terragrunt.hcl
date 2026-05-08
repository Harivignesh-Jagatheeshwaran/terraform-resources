# accounts/dev/us-east-2/eks/001-ecommerce-website/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}


inputs = {
  cluster_name    = "dev-ecommerce-eks"
  cluster_version = "1.29"

  # pass directly — no dependency on vpc module
  vpc_id             = "vpc-08e7df6413ee49c38"
  private_subnet_ids = ["subnet-05b57ba5e642253a3", "subnet-07f8afd94568d6193"]
  public_subnet_ids  = ["subnet-00e2be5310e4ebb0d", "subnet-091a480a3bab66255"]

  node_group_name             = "dev-ecommerce-nodes"
  node_group_instance_types   = ["t3.medium"]
  node_group_desired_capacity = 2
}