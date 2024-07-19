variable "aws_profile" {
  type    = string
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
  default     = 1

}
variable "podmaxsize" {
  description = "The maximum size of the EKS managed node group"
  type        = number
  default     = 6

}
variable "desired_size" {
  description = "The desired size of the EKS managed node group"
  type        = number
  default     = 2

}
variable "namespaces" {
  description = "List of namespaces"
  type        = list(string)
  default     = ["namespace1", "namespace2", "namespace3", "cluster-autoscaler"]

}


variable "kafka_version" {
  description = "The version of the Kafka chart."
  default     = "25.2.0"
}

variable "namespace_kafka" {
  description = "The namespace for Kafka."
  default     = "namespace2"
}

variable "listeners_client_protocol" {
  description = "The protocol for Kafka client listeners."
  default     = "PLAINTEXT"
}

variable "listeners_controller_protocol" {
  description = "The protocol for Kafka controller listeners."
  default     = "PLAINTEXT"
}

variable "listeners_interbroker_protocol" {
  description = "The protocol for Kafka interbroker listeners."
  default     = "PLAINTEXT"
}

variable "listeners_external_protocol" {
  description = "The protocol for Kafka external listeners."
  default     = "PLAINTEXT"
}

variable "controller_replica_count" {
  description = "The replica count for the Kafka controller."
  default     = 0
}

variable "broker_replica_count" {
  description = "The replica count for Kafka brokers."
  default     = 3
}

variable "broker_persistence_size" {
  description = "The persistence size for Kafka brokers."
  default     = "4Gi"
}

variable "service_account_create" {
  description = "Whether to create a service account for Kafka."
  default     = "false"
}

variable "provisioning_enabled" {
  description = "Whether provisioning is enabled for Kafka."
  default     = "true"
}

variable "provisioning_num_partitions" {
  description = "The number of partitions for Kafka provisioning."
  default     = 3
}

variable "provisioning_replication_factor" {
  description = "The replication factor for Kafka provisioning."
  default     = 2
}

variable "provisioning_topic_name" {
  description = "The name of the Kafka provisioning topic."
  default     = "cve"
}

variable "kraft_enabled" {
  description = "Whether Kraft is enabled for Kafka."
  default     = "false"
}

variable "zookeeper_replica_count" {
  description = "The replica count for Kafka Zookeeper."
  default     = 2
}

variable "zookeeper_enabled" {
  description = "Whether Zookeeper is enabled for Kafka."
  default     = "true"
}

variable "zookeeper_persistence_size" {
  description = "The persistence size for Kafka Zookeeper."
  default     = "2Gi"
}

variable "postgresql_version" {
  description = "The version of the PostgreSQL chart."
  default     = "14.2.7"
}

variable "namespace_postgresql" {
  description = "The namespace for PostgreSQL."
  default     = "namespace3"
}

variable "postgresql_postgres_password" {
  description = "The password for the PostgreSQL postgres user."
  default     = "changeme"
}

variable "postgresql_username" {
  description = "The username for the PostgreSQL database."
  default     = "cve"
}

variable "postgresql_password" {
  description = "The password for the PostgreSQL database user."
  default     = "changeme"
}

variable "postgresql_database" {
  description = "The name of the PostgreSQL database."
  default     = "mydatabase"
}

variable "postgresql_repmgr_username" {
  description = "The repmgr username for PostgreSQL."
  default     = "repmgr"
}

variable "postgresql_repmgr_password" {
  description = "The repmgr password for PostgreSQL."
  default     = "repmgrpassword"
}

variable "postgresql_repmgr_database" {
  description = "The repmgr database for PostgreSQL."
  default     = "repmgr"
}

variable "pgpool_custom_usernames" {
  description = "The custom usernames for pgpool."
  default     = "cve"
}

variable "pgpool_custom_passwords" {
  description = "The custom passwords for pgpool."
  default     = "changeme"
}

variable "pgpool_num_init_children" {
  description = "The number of initial children for pgpool."
  default     = 32
}

variable "pgpool_max_pool" {
  description = "The maximum pool size for pgpool."
  default     = 100
}

variable "pgpool_child_life_time" {
  description = "The child lifetime for pgpool."
  default     = 300
}

variable "pgpool_connection_life_time" {
  description = "The connection lifetime for pgpool."
  default     = 600
}

variable "pgpool_client_idle_limit" {
  description = "The client idle limit for pgpool."
  default     = 60
}

variable "github_username" {
}

variable "github_token" {
}

variable "dh_username" {
}

variable "dh_token" {
}

variable "dh_email" {
}
