output "service_name" {
  description = "MySQL service name"
  value       = kubernetes_service.mysql.metadata[0].name
}