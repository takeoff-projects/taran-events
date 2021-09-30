gcloud builds submit --tag gcr.io/roi-takeoff-user10/events-app:latest
terraform init && terraform apply -auto-approve --var="project_id=roi-takeoff-user10"