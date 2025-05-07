resource "kubernetes_ingress_v1" "microservices" {
  metadata {
    name      = "microservices-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          path = "/users"
          backend {
            service {
              name = "user-service"
              port {
                number = 5000
              }
            }
          }
        }
        path {
          path = "/movies"
          backend {
            service {
              name = "movie-service"
              port {
                number = 5001
              }
            }
          }
        }
        path {
          path = "/showtimes"
          backend {
            service {
              name = "showtime-service"
              port {
                number = 5002
              }
            }
          }
        }
        path {
          path = "/bookings"
          backend {
            service {
              name = "booking-service"
              port {
                number = 5003
              }
            }
          }
        }
      }
    }
  }
}