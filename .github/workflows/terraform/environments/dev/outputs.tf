output "ingress_hostname" {
  description = "Hostname for accessing the services"
  value       = module.ingress.ingress_hostname
}