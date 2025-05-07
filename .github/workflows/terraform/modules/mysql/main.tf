resource "kubernetes_namespace" "movie_booking" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "db_secrets" {
  metadata {
    name      = "db-secrets"
    namespace = var.namespace
  }

  data = {
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
    DB_USER             = "root"
    DB_PASSWORD         = var.mysql_root_password
  }

  type = "Opaque"
}

resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
  }
  spec {
    capacity = {
      storage = var.storage_size
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = ""
    host_path {
      path = "/var/lib/mysql-new"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    volume_name = kubernetes_persistent_volume.mysql_pv.metadata[0].name
    storage_class_name = ""
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        init_container {
          name    = "nuclear-clean"
          image   = "busybox"
          command = ["sh", "-c", "rm -rf /var/lib/mysql/* && ls -la /var/lib/mysql"]
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        container {
          name  = "mysql"
          image = "mysql:8.0.42"
          command = [
            "sh",
            "-c",
            <<-EOT
              if [ ! -f /var/lib/mysql/mysql ]; then
                mysqld --initialize-insecure
              fi
              exec mysqld
            EOT
          ]
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "MYSQL_ROOT_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}