output "ingress_hostname" {
  description = "Hostname of the ingress"
  value       = kubernetes_ingress_v1.microservices.spec[0].rule[0].host
}