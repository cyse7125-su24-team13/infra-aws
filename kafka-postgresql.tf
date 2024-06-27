provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "kafka" {
  depends_on = [module.eks]

  name       = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  namespace  = "namespace2"
  version    = "25.2.0"

  set {
    name  = "listeners.client.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.controller.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.interbroker.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "listeners.external.protocol"
    value = "PLAINTEXT"
  }

  set {
    name  = "controller.replicaCount"
    value = "0"
  }

  set {
    name  = "broker.replicaCount"
    value = "3"
  }

  set {
    name  = "broker.persistence.size"
    value = "4Gi"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "provisioning.enabled"
    value = "true"
  }

  set {
    name  = "provisioning.numPartitions"
    value = "3"
  }

  set {
    name  = "provisioning.replicationFactor"
    value = "1"
  }

  set {
    name  = "provisioning.topics[0].name"
    value = "cve"
  }

  set {
    name  = "kraft.enabled"
    value = "false"
  }

  set {
    name  = "zookeeper.enabled"
    value = "true"
  }

  set {
    name  = "zookeeper.persistence.size"
    value = "2Gi"
  }
}

resource "helm_release" "postgresql_ha" {
  depends_on = [module.eks]

  name       = "postgresql-ha"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  namespace  = "namespace3"
  version    = "14.2.7"

  set {
    name  = "postgresql.postgresPassword"
    value = "changeme"
  }

  set {
    name  = "postgresql.username"
    value = "cve"
  }

  set {
    name  = "postgresql.password"
    value = "changeme"
  }

  set {
    name  = "postgresql.database"
    value = "mydatabase"
  }

  set {
    name  = "postgresql.repmgrUsername"
    value = "repmgr"
  }

  set {
    name  = "postgresql.repmgrPassword"
    value = "repmgrpassword"
  }

  set {
    name  = "postgresql.repmgrDatabase"
    value = "repmgr"
  }

  set {
    name  = "pgpool.customUsers.usernames"
    value = "cve"
  }

  set {
    name  = "pgpool.customUsers.passwords"
    value = "changeme"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


