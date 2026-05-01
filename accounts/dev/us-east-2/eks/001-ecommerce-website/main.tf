module "eks" {
  source = "../../../../../modules/eks"

  cluster_name                  = var.cluster_name
  cluster_version               = var.cluster_version
  vpc_id                        = var.vpc_id
  subnet_ids                    = concat(var.private_subnet_ids, var.public_subnet_ids)
}