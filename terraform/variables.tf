variable "mysql_image_version" {
  description = "Version of MySQL image to use"
  type        = string
  default     = "8.0.42"
}

variable "service_replicas" {
  description = "Number of replicas for each microservice"
  type        = number
  default     = 2
}