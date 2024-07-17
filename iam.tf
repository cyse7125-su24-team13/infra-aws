resource "aws_iam_role" "cluster_role" {
  name       = "eks_iam_cluster_role_tf"
  depends_on = [data.aws_iam_policy_document.cluster_assume_role_policy]
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
}

resource "aws_iam_role" "node_role" {
  name       = "eks_iam_node_role_tf"
  depends_on = [data.aws_iam_policy_document.cluster_assume_role_policy]
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "cluster-autoscaler-policy"
  description = "Policy for Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstances",
          "ec2:DescribeLaunchTemplateVersions",
          "eks:DescribeNodegroup"
        ],
        Resource = "*"
      }
    ]
  })
}


locals {
  oidc_provider_id = split("oidc.eks.us-east-1.amazonaws.com/id/", module.eks.oidc_provider_arn)[1]
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" = {
            "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_provider_id}:sub" = "system:serviceaccount:cluster-autoscaler:cluster-autoscaler",
            "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_provider_id}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cluster_autoscaler_policy" {
  role       = aws_iam_role.cluster_autoscaler_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}





