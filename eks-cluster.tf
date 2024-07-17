data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

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
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  create_iam_role                          = var.create_iam_role
  iam_role_arn                             = aws_iam_role.cluster_role.arn
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  vpc_id                                   = aws_vpc.main.id
  subnet_ids                               = aws_subnet.private[*].id
  control_plane_subnet_ids                 = aws_subnet.public[*].id
  cluster_enabled_log_types                = var.cluster_enabled_log_types
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  eks_managed_node_groups = {
    example = {
      ami_type                 = var.ami_type
      instance_types           = var.instance_types
      create_iam_role          = true
      capacity_type            = var.capacity_type
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        additional                         = aws_iam_policy.node_additional.arn
      }
      min_size     = var.podminsize
      max_size     = var.podmaxsize
      desired_size = var.desired_size
      subnet_ids   = aws_subnet.private[*].id
    }
  }

  tags = var.tagseks
}

resource "aws_iam_policy" "node_additional" {
  name        = "node_group-additional"
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

  tags = var.tagseks
}

module "ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  attach_ebs_csi_policy = true
  role_policy_arns = {
    "AmazonEKS_CSI_Driver" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  role_name = "ebs-csi-irsa-role"

  oidc_providers = {
    example = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
resource "kubernetes_namespace" "example" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
  }

  depends_on = [module.eks, data.aws_eks_cluster.eks, data.aws_eks_cluster_auth.eks]
}

