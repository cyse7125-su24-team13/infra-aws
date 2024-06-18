resource "aws_iam_role" "cluster_role" {
  name       = "eks_cluster_role_tf"
  depends_on = [data.aws_iam_policy_document.eks_cluster_assume_role_policy]
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}

resource "aws_iam_role" "node_role" {
  name       = "eks_node_role_tf"
  depends_on = [data.aws_iam_policy_document.eks_cluster_assume_role_policy]
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
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





