variable "db_name" {
  type = string
  default = "devops_db"
}

variable "db_user" {
  type = string
  default = "devops_user"
}

variable "db_password" {
  type = string
  default = "newsecurepassword789"
}

variable "app_port_external" {
  type = number
  default = 8081
}
