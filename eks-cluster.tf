module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
  create_iam_role         = false
  iam_role_arn            = aws_iam_role.eks_cluster_iam_role.arn
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  create_kms_key          = true
  enable_kms_key_rotation = true

  eks_managed_node_groups = {
    example = {
      ami_type                 = "AL2_x86_64"
      instance_types           = ["t2.micro"]
      create_iam_role          = true
      capacity_type            = "ON_DEMAND"
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        additional                         = aws_iam_policy.node_additional.name
      }
      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }

  tags = local.tags
}
resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}
