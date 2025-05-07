variable "namespace" {
  description = "Kubernetes namespace for MySQL resources"
  type        = string
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "Size of the persistent volume"
  type        = string
  default     = "5Gi"
}