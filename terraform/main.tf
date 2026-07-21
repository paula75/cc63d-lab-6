provider "google" {
  project = "seminario-gestion-incidentes"
  region  = "southamerica-west1"
}

# 1. Repositorio de Artifact Registry
resource "google_artifact_registry_repository" "incidentes" {
  location      = "southamerica-west1"
  repository_id = "incidentes"
  format        = "DOCKER"
}

# 2. Servicio de Cloud Run
resource "google_cloud_run_v2_service" "incidentes" {
  name                 = "incidentes-ci"
  location             = "southamerica-west1"
  ingress              = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled = true # Habilita acceso público sin autenticación

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Contenedor dummy inicial
      ports {
        container_port = 8080
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image, # Evita que Terraform sobrescriba tus despliegues de GitHub
    ]
  }
}

# 3. Trigger de Cloud Build conectado a GitHub
resource "google_cloudbuild_trigger" "incidentes_trigger" {
  name     = "rmgpgab-cloudbuild-incidentes-southamerica-west1-paula75-cc6uqe"
  location = "southamerica-west1"

  github {
    owner = "paula75"
    name  = "cc63d-lab-6"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml" # Lee tu archivo cloudbuild.yaml de tu repositorio
}
