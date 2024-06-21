# EKS Cluster with Terraform

This repository contains the Terraform configuration for setting up an Amazon EKS cluster with necessary IAM roles, policies, managed node groups, and add-ons.

## Prerequisites

Before you begin, ensure you have the following:

- Terraform installed
- AWS CLI configured with appropriate permissions
- An existing VPC with public and private subnets

## Variables

This configuration requires several variables to be defined. You can customize these in a `variables.tf` file.

- `cluster_name`: Name of the EKS cluster
- `cluster_version`: Version of the EKS cluster
- `create_iam_role`: Boolean to create a new IAM role for the cluster
- `cluster_endpoint_private_access`: Boolean to enable private access to the cluster endpoint
- `cluster_endpoint_public_access`: Boolean to enable public access to the cluster endpoint
- `cluster_enabled_log_types`: List of log types to enable for the cluster
- `enable_cluster_creator_admin_permissions`: Boolean to enable admin permissions for the cluster creator
- `vpc_id`: ID of the VPC
- `subnet_ids`: List of private subnet IDs
- `control_plane_subnet_ids`: List of public subnet IDs for the control plane
- `ami_type`: AMI type for the node group instances
- `instance_types`: List of instance types for the node groups
- `capacity_type`: Capacity type for the node groups (e.g., ON_DEMAND, SPOT)
- `podminsize`: Minimum size of the node group
- `podmaxsize`: Maximum size of the node group
- `desired_size`: Desired size of the node group
- `tagseks`: Tags to apply to the EKS resources

## Usage

1. **Clone the repository**:

    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. **Create a `variables.tf` file** to define the necessary variables:

    ```hcl
    variable "cluster_name" {}
    variable "cluster_version" {}
    variable "create_iam_role" {}
    variable "cluster_endpoint_private_access" {}
    variable "cluster_endpoint_public_access" {}
    variable "vpc_id" {}
    variable "subnet_ids" {}
    variable "control_plane_subnet_ids" {}
    variable "cluster_enabled_log_types" {
      type = list(string)
    }
    variable "enable_cluster_creator_admin_permissions" {}
    variable "ami_type" {}
    variable "instance_types" {
      type = list(string)
    }
    variable "capacity_type" {}
    variable "podminsize" {}
    variable "podmaxsize" {}
    variable "desired_size" {}
    variable "tagseks" {
      type = map(string)
    }
    ```

3. **Initialize and apply the Terraform configuration**:

    ```bash
    terraform init
    terraform apply
    ```

    This will provision the EKS cluster, node groups, and associated IAM roles and policies.

## Configuration

Here is a brief overview of the main components in the configuration:

### EKS Module

```hcl
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

  create_iam_role           = var.create_iam_role
  iam_role_arn              = aws_iam_role.cluster_role.arn
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  vpc_id                    = aws_vpc.main.id
  subnet_ids                = aws_subnet.private[*].id
  control_plane_subnet_ids = aws_subnet.public[*].id
  cluster_enabled_log_types = var.cluster_enabled_log_types
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
    }
  }

  tags = var.tagseks
}
