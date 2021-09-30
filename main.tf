provider "google" {
  credentials = file("gcp_key.json")
  project = var.project_id
  region  = var.provider_region
}

resource "google_cloud_run_service" "events-website" {
  name     = "events-website"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/roi-takeoff-user10/events-app:latest"
        env {
          name = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
      }
        env {
          name = "BACKEND_URL"
          value = "https://events-api-4kad4w6jba-uc.a.run.app/events"
        }
    }
  }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.events-website.location
  project     = google_cloud_run_service.events-website.project
  service     = google_cloud_run_service.events-website.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
