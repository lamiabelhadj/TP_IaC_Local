# main.tf (Assurez-vous que ce code est bien dans votre fichier)

variable "db_user" {
  description = "Utilisateur pour la base de données PostgreSQL"
  type        = string
  default     = "user"
}

variable "db_password" {
  description = "Mot de passe pour la base de données PostgreSQL"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "db_name" {
  description = "Nom de la base de données PostgreSQL"
  type        = string
  default     = "mydatabase"
}

variable "app_port_external" {
  description = "Port externe pour l'application web (ex: 8080)"
  type        = number
  default     = 8080
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      # Nous utilisons une version 2.x stable pour éviter le bug de la 3.x
      version = "~> 2.15.0" 
    }
  }
}

provider "docker" {
  # C'est la ligne clé pour la correction de l'API
  api_version = "1.52"
}

resource "docker_image" "postgres_image" {
  name           = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id

  ports {
    internal = 5432
    external = 5432
  }

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

resource "docker_image" "app_image" {
  name = "tp-web-app:latest"

  build {
    context    = "."
    dockerfile = "Dockerfile_app"
  }
}

resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.image_id

  depends_on = [
    docker_container.db_container
  ]

  ports {
    internal = 82
    external = var.app_port_external
  }
}