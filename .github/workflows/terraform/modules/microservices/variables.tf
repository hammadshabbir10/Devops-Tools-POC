variable "namespace" {
  description = "Kubernetes namespace for microservices"
  type        = string
}

variable "mysql_host" {
  description = "MySQL host address"
  type        = string
}

variable "image_versions" {
  description = "Versions for each microservice image"
  type        = map(string)
}