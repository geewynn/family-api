resource "helm_release" "mongo_db" {
  name       = "mongo-db"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"

  set {
    name  = "auth.rootPassword"
    value = "dbrootpassword"
  }
  set {
    name  = "auth.username"
    value = "dbuser"
  }

  set {
    name  = "auth.password"
    value = "dbtestpassword"
  }

  set {
    name  = "auth.database"
    value = "appDB"
  }

  set {
    name  = "architecture"
    value = "replicaset"
  }

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "externalAccess.enabled"
    value = true
  }

  set {
    name  = "externalAccess.service.type"
    value = "LoadBalancer"
  }

    set {
        name  = "externalAccess.service.port"
        value = 27017
    }

    set {
        name  = "externalAccess.autoDiscovery.enabled"
        value = true
    }

    set {
        name  = "serviceAccount.create"
        value = true
    }

    set {
        name  = "rbac.create"
        value = true
    }

    depends_on = [google_container_node_pool.primary]

}
