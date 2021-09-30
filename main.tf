# main.tf

terraform {
    required_version = ">=0.14"

    required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
    provider "google" {
        project = "roi-takeoff-user10"
  }

    resources "google_ project_service" "run_api" {
        service = "run.googleapis.com"

        disable_on_destroy = true
    }

    # Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  name = "app"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/roi-takeoff-user10/events-app:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}

}
