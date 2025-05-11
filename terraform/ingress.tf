resource "kubernetes_ingress_v1" "microservices_ingress" {
  metadata {
    name      = "microservices-ingress"
    namespace = kubernetes_namespace.movie-booking.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "moviebooking.local"
      http {
        path {
          path = "/(user|users)(/|$)(.*)"
          path_type = "ImplementationSpecific"
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
          path = "/movies(/|$)(.*)"
          path_type = "ImplementationSpecific"
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
          path = "/showtimes(/|$)(.*)"
          path_type = "ImplementationSpecific"
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
          path = "/bookings(/|$)(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "booking-service"
              port {
                number = 5003
              }
            }
          }
        }
        path {
          path = "/health"
          path_type = "Prefix"
          backend {
            service {
              name = "user-service"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}