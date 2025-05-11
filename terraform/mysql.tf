resource "kubernetes_namespace" "movie-booking" {
  metadata {
    name = "movie-booking"
  }
}

resource "kubernetes_secret" "db_secrets" {
  metadata {
    name      = "db-secrets"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }

  data = {
    MYSQL_ROOT_PASSWORD = base64encode("mostwanted3z")
    DB_USER             = base64encode("root")
    DB_PASSWORD         = base64encode("mostwanted3z")
  }

  type = "Opaque"
}

resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = ""
    persistent_volume_source {
      host_path {
        path = "/var/lib/mysql-new"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mysql_pv.metadata[0].name
    storage_class_name = ""
  }
}

resource "kubernetes_config_map" "mysql_init" {
  metadata {
    name      = "mysql-init"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  data = {
    "init.sql" = file("${path.module}/mysql_files/init.sql")
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
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
          name    = "clean-data-dir"
          image   = "busybox"
          command = ["sh", "-c", "rm -rf /var/lib/mysql/* && ls -la /var/lib/mysql"]
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        init_container {
          name    = "init-db"
          image   = "busybox"
          command = ["sh", "-c", "cp /docker-entrypoint-initdb.d/init.sql /var/lib/mysql/ && echo \"Init file copied\""]
          volume_mount {
            name       = "init-script"
            mount_path = "/docker-entrypoint-initdb.d"
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        container {
          name  = "mysql"
          image = "mysql:8.0.42"
          port {
            container_port = 3306
          }
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
          volume_mount {
            name       = "init-scripts-dir"
            mount_path = "/docker-entrypoint-initdb.d"
          }
          readiness_probe {
            exec {
              command = ["mysqladmin", "ping", "-uroot", "-p$(MYSQL_ROOT_PASSWORD)"]
            }
            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 5
          }
        }
        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
        volume {
          name = "init-script"
          config_map {
            name = kubernetes_config_map.mysql_init.metadata[0].name
            items {
              key  = "init.sql"
              path = "init.sql"
            }
          }
        }
        volume {
          name = "init-scripts-dir"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
}