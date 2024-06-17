module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"
  cluster_name                    = "my-cluster"
  cluster_version                 = "1.30"
  cluster_endpoint_private_access = true // later set to false
  cluster_endpoint_public_access  = true // later set to false
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
enable_irsa                    = true
eks_managed_node_group_defaults = {
    
}
}
