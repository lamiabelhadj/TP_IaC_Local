

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}




# Pull de l’image PostgreSQL depuis Docker Hub
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

# Conteneur PostgreSQL
resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.latest

  # Mapping de ports
  ports {
    internal = 5432
    external = 5432
  }

  # Variables d’environnement (via variables.tf)
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}



# Construction de l’image web depuis Dockerfile_app
resource "docker_image" "app_image" {
  name = "tp-web-app:latest"

  build {
    context    = "."
    dockerfile = "Dockerfile_app"
  }
}

# Conteneur de l’application Web
resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.latest

  # L'application dépend de la disponibilité de la DB
  depends_on = [
    docker_container.db_container
  ]

  # Mapping des ports
  ports {
    internal = 80
    external = var.app_port_external
  }
}
