locals {
  services = {
    "user-service" = {
      port = 5000
      image = "22i1140/microservices-user-service:v1"
    }
    "movie-service" = {
      port = 5001
      image = "22i1140/microservices-movie-service:v1"
    }
    "showtime-service" = {
      port = 5002
      image = "22i1140/microservices-showtime-service:v1"
    }
    "booking-service" = {
      port = 5003
      image = "22i1140/microservices-booking-service:v1"
    }
  }
}

resource "kubernetes_config_map" "db_config" {
  metadata {
    name      = "db-config"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  data = {
    MYSQL_DATABASE = "movie-booking"
    DB_HOST        = "mysql.movie-booking.svc.cluster.local"
    DB_NAME        = "movie-booking"
    DB_PORT        = "3306"
  }
}

resource "kubernetes_config_map" "services_config" {
  metadata {
    name      = "services-config"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  data = {
    MOVIE_SERVICE_URL   = "http://movie-service:5001"
    SHOWTIME_SERVICE_URL = "http://showtime-service:5002"
    BOOKING_SERVICE_URL  = "http://booking-service:5003"
    USER_SERVICE_URL     = "http://user-service:5000"
  }
}

resource "kubernetes_deployment" "microservices" {
  for_each = local.services

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  spec {
    replicas = 2
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = each.key
      }
    }
    template {
      metadata {
        labels = {
          app = each.key
        }
      }
      spec {
        init_container {
          name    = "wait-for-mysql"
          image   = "busybox"
          command = ["sh", "-c", "until nc -z mysql.movie-booking.svc.cluster.local 3306; do sleep 2; echo \"Waiting for MySQL...\"; done"]
        }
        container {
          name  = each.key
          image = each.value.image
          port {
            container_port = each.value.port
          }
          env {
            name = "DB_HOST"
            value = "mysql.movie-booking.svc.cluster.local"
          }
          env {
            name = "DB_PORT"
            value = "3306"
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "DB_USER"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secrets.metadata[0].name
                key  = "DB_PASSWORD"
              }
            }
          }
          env {
            name = "DB_NAME"
            value = "movie-booking"
          }
          env {
            name = "FLASK_ENV"
            value = "production"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = each.value.port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "microservices" {
  for_each = local.services

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
  }
  spec {
    selector = {
      app = each.key
    }
    port {
      port        = each.value.port
      target_port = each.value.port
    }
    type = "NodePort"
  }
}