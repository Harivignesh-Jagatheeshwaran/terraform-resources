# accounts/dev/us-east-2/eks/002-ecommerce-website/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/eks"    # ← absolute path using terragrunt function
}


inputs = {
  cluster_name    = "dev-ecommerce-eks-002"
  cluster_version = "1.30"

  # pass directly — no dependency on vpc module
  vpc_id     = "vpc-0cfed083738963b86"
  subnet_ids = ["subnet-0cbc563adce5287a3", "subnet-06fbd5601c599131e", "subnet-0d4999b9f72f13e45", "subnet-00816edaf89e070ce"]

  node_group_name             = "dev-ecommerce-nodes-002"
  node_group_instance_types   = ["t3.medium"]
  node_group_desired_capacity = 2
}