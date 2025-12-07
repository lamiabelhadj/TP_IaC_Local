# Définition des variables nécessaires pour le fichier
variable "db_user" {
  description = "Utilisateur pour la base de données PostgreSQL"
  type        = string
  default     = "user" # Valeur par défaut, à remplacer dans un fichier .tfvars
}

variable "db_password" {
  description = "Mot de passe pour la base de données PostgreSQL"
  type        = string
  default     = "password" # Valeur par défaut, à remplacer
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

---

# Configuration du Backend et des Fournisseurs
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  # CORRECTION DE L'ERREUR D'API : 
  # Force le fournisseur Docker à utiliser une version de l'API supportée 
  # par le daemon (1.52 est celle que votre Docker Engine supporte).
  api_version = "1.52" 
}

---

# Ressources Docker pour PostgreSQL

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

---

# Ressources Docker pour l'Application Web

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

  # Assure que la base de données est démarrée avant l'application
  depends_on = [
    docker_container.db_container
  ]

  ports {
    internal = 82
    external = var.app_port_external
  }
}