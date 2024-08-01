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
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters"
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

resource "aws_iam_policy" "fluentbit_cloudwatch_policy" {
  name        = "FluentBitCloudWatchPolicy"
  description = "Policy for Fluent Bit to send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "fluentbit_role" {
  name = "FluentBitRole"

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
            "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_provider_id}:sub" = "system:serviceaccount:kube-system:fluent-bit",
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_fluentbit_policy" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_cloudwatch_policy.arn
}

# resource "kubernetes_cluster_role" "fluent_bit" {
#   metadata {
#     name = "fluent-bit"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["pods", "namespaces", "nodes", "persistentvolumeclaims"]
#     verbs      = ["get", "list", "watch"]
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["pods/log"]
#     verbs      = ["get", "list", "watch", "create"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "fluent_bit" {
#   metadata {
#     name = "fluent-bit"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.fluent_bit.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = "fluent-bit"
#     namespace = "kube-system"
#   }
# }




