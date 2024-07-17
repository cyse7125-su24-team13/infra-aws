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
  namespace  = var.namespace_kafka
  version    = var.kafka_version

  set {
    name  = "listeners.client.protocol"
    value = var.listeners_client_protocol
  }

  set {
    name  = "listeners.controller.protocol"
    value = var.listeners_controller_protocol
  }

  set {
    name  = "listeners.interbroker.protocol"
    value = var.listeners_interbroker_protocol
  }

  set {
    name  = "listeners.external.protocol"
    value = var.listeners_external_protocol
  }

  set {
    name  = "controller.replicaCount"
    value = var.controller_replica_count
  }

  set {
    name  = "broker.replicaCount"
    value = var.broker_replica_count
  }

  set {
    name  = "broker.persistence.size"
    value = var.broker_persistence_size
  }

  set {
    name  = "serviceAccount.create"
    value = var.service_account_create
  }

  set {
    name  = "provisioning.enabled"
    value = var.provisioning_enabled
  }

  set {
    name  = "provisioning.numPartitions"
    value = var.provisioning_num_partitions
  }

  set {
    name  = "provisioning.replicationFactor"
    value = var.provisioning_replication_factor
  }

  set {
    name  = "provisioning.topics[0].name"
    value = var.provisioning_topic_name
  }

  set {
    name  = "kraft.enabled"
    value = var.kraft_enabled
  }

  set {
    name  = "zookeeper.replicaCount"
    value = var.zookeeper_replica_count
  }

  set {
    name  = "zookeeper.enabled"
    value = var.zookeeper_enabled
  }

  set {
    name  = "zookeeper.persistence.size"
    value = var.zookeeper_persistence_size
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight"
    value = "100"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey"
    value = "topology.kubernetes.io/zone"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key"
    value = "app.kubernetes.io/name"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0]"
    value = "kafka"
  }
}

resource "helm_release" "postgresql_ha" {
  depends_on = [module.eks]

  name       = "postgresql-ha"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  namespace  = var.namespace_postgresql
  version    = var.postgresql_version

  set {
    name  = "postgresql.postgresPassword"
    value = var.postgresql_postgres_password
  }

  set {
    name  = "postgresql.username"
    value = var.postgresql_username
  }

  set {
    name  = "postgresql.password"
    value = var.postgresql_password
  }

  set {
    name  = "postgresql.database"
    value = var.postgresql_database
  }

  set {
    name  = "postgresql.repmgrUsername"
    value = var.postgresql_repmgr_username
  }

  set {
    name  = "postgresql.repmgrPassword"
    value = var.postgresql_repmgr_password
  }

  set {
    name  = "postgresql.repmgrDatabase"
    value = var.postgresql_repmgr_database
  }

  set {
    name  = "pgpool.customUsers.usernames"
    value = var.pgpool_custom_usernames
  }

  set {
    name  = "pgpool.customUsers.passwords"
    value = var.pgpool_custom_passwords
  }

  set {
    name  = "pgpool.numInitChildren"
    value = var.pgpool_num_init_children
  }

  set {
    name  = "pgpool.maxPool"
    value = var.pgpool_max_pool
  }

  set {
    name  = "pgpool.childLifeTime"
    value = var.pgpool_child_life_time
  }

  set {
    name  = "pgpool.connectionLifeTime"
    value = var.pgpool_connection_life_time
  }

  set {
    name  = "pgpool.clientIdleLimit"
    value = var.pgpool_client_idle_limit
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
