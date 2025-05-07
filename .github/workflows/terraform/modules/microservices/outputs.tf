output "service_endpoints" {
  description = "Map of service endpoints"
  value = {
    for service in keys(var.image_versions) :
    service => "${service}.${var.namespace}.svc.cluster.local"
  }
}