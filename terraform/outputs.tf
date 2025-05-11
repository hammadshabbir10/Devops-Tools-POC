output "ingress_host" {
  value = kubernetes_ingress_v1.microservices_ingress.spec[0].rule[0].host
}

output "service_endpoints" {
  value = {
    for service in keys(local.services) :
    service => "http://${kubernetes_ingress_v1.microservices_ingress.spec[0].rule[0].host}"
  }
}
output "sql_file_path" {
  value = "../docker/mysql/init.sql"
}

output "sql_file_exists" {
  value = fileexists("../docker/mysql/init.sql")
}
