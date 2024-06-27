resource "helm_release" "postgresql_ha" {
  depends_on = [module.eks]

  name       = "postgresql-ha"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql-ha"
  namespace  = "default"
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

  set {
    name  = "pgpool.numInitChildren"
    value = "32"
  }

  set {
    name  = "pgpool.maxPool"
    value = "100"
  }

  set {
    name  = "pgpool.childLifeTime"
    value = "300"
  }

  set {
    name  = "pgpool.connectionLifeTime"
    value = "600"
  }

  set {
    name  = "pgpool.clientIdleLimit"
    value = "60"
  }
}
