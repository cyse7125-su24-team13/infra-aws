variable "aws_profile" {
  type = string
  default = ""
}
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-cluster3"
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "cluster_addons" {
  description = "Map of EKS cluster addons and their configuration"
  type        = map(any)
  default = {
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
      service_account_role_arn = null
    }
  }
}

variable "create_iam_role" {
  description = "Whether to create a new IAM role for the EKS cluster"
  type        = bool
  default     = false
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role to be used for the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "control_plane_subnet_ids" {
  description = "List of public subnet IDs for the EKS control plane"
  type        = list(string)
  default     = []
}

variable "cluster_enabled_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the EKS cluster creator"
  type        = bool
  default     = true
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups and their configuration"
  type        = map(any)
  default = {
    example = {
      ami_type                 = "AL2_x86_64"
      instance_types           = ["c3.large"]
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
        additional                         = ""
      }
      min_size     = 3
      max_size     = 6
      desired_size = 3
    }
  }
}

variable "tagseks" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Example    = "ex-eks-mng1"
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

variable "ami_type" {
  description = "The AMI type for the EKS managed node group"
  type        = string
  default     = "AL2_x86_64"
}
variable "instance_types" {
  description = "List of instance types for the EKS managed node group"
  type        = list(string)
  default     = ["c3.large"]
  
}
variable "capacity_type" {
  description = "The capacity type for the EKS managed node group"
  type        = string
  default     = "ON_DEMAND"
}

variable "podminsize" {
  description = "The minimum size of the EKS managed node group"
  type        = number
  default     = 3
  
}
variable "podmaxsize" {
  description = "The maximum size of the EKS managed node group"
  type        = number
  default     = 6
  
}
variable "desired_size" {
  description = "The desired size of the EKS managed node group"
  type        = number
  default     = 3
  
}
variable "namespaces" {
  description = "List of namespaces"
  type        = list(string)
  default     = ["namespace1", "namespace2", "namespace3"]
  
}
