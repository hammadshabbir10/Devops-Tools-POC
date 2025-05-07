resource "kubernetes_config_map" "services_config" {
  metadata {
    name      = "services-config"
    namespace = var.namespace
  }
  data = {
    MOVIE_SERVICE_URL    = "http://movie-service:5001"
    SHOWTIME_SERVICE_URL = "http://showtime-service:5002"
    BOOKING_SERVICE_URL  = "http://booking-service:5003"
    USER_SERVICE_URL     = "http://user-service:5000"
  }
}

locals {
  services = {
    "user-service" = {
      port = 5000
      env = []
    }
    "movie-service" = {
      port = 5001
      env = []
    }
    "showtime-service" = {
      port = 5002
      env = []
    }
    "booking-service" = {
      port = 5003
      env = [
        {
          name  = "DB_HOST"
          value = var.mysql_host
        },
        {
          name  = "DB_PORT"
          value = "3306"
        },
        {
          name  = "DB_NAME"
          value = "movie_booking"
        }
      ]
    }
  }
}

resource "kubernetes_deployment" "microservices" {
  for_each = local.services

  metadata {
    name      = each.key
    namespace = var.namespace
  }
  spec {
    replicas = 2
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
          command = ["sh", "-c", "until nc -z ${var.mysql_host} 3306; do sleep 2; echo \"Waiting for MySQL...\"; done"]
        }
        container {
          name  = each.key
          image = "22i1140/microservices-${each.key}:${lookup(var.image_versions, each.key, "latest")}"
          port {
            container_port = each.value.port
          }
          env_from {
            secret_ref {
              name = "db-secrets"
            }
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.services_config.metadata[0].name
            }
          }
          dynamic "env" {
            for_each = each.value.env
            content {
              name  = env.value.name
              value = env.value.value
            }
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
              path = "/health"
              port = each.value.port
            }
            initial_delay_seconds = 30
            period_seconds       = 10
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
    namespace = var.namespace
  }
  spec {
    selector = {
      app = each.key
    }
    port {
      port       = each.value.port
      target_port = each.value.port
    }
  }
}