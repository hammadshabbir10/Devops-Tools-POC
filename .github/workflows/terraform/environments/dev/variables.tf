variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
  sensitive   = true
}

variable "image_versions" {
  description = "Versions for each microservice image"
  type        = map(string)
}