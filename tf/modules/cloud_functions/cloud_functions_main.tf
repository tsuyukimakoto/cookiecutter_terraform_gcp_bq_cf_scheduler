
resource "google_project_iam_member" "cloud_function_invoker_iam_member" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.service_account_email_cloud_functions}"
}

resource "google_storage_bucket" "cloud_functions_source" {
  name     = "${var.project_prefix}cloud-functions-source-bucket"
  location = "ASIA" # FIXME if you need

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "github_actions_bucket_iam_member" {
  bucket = google_storage_bucket.cloud_functions_source.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email_github_actions}"
}

resource "google_project_iam_member" "github_actions_developer_role" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member = "serviceAccount:${var.service_account_email_github_actions}"
}

resource "google_project_iam_member" "github_actions_cloudbuild_role" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member = "serviceAccount:${var.service_account_email_github_actions}"
}

resource "google_project_iam_member" "github_actions_act_as_role" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${var.service_account_email_github_actions}"
}

resource "google_project_iam_member" "bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member = "serviceAccount:${var.service_account_email_cloud_functions}"
}

resource "google_bigquery_dataset_iam_member" "dataset_viewer" {
  dataset_id = var.bigquery_dataset_id
  role       = "roles/bigquery.dataViewer"
  member = "serviceAccount:${var.service_account_email_cloud_functions}"
}

resource "google_cloudfunctions_function" "default" {

  name        = "cfunction-default" # FIXME if you need and you change this, grep 'cfunction-default' and change all.
  description = "Function to access BigQuery"
  runtime     = "python311" # FIXME if you need

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.cloud_functions_source.name
  source_archive_object = "default-code.zip" # If you make changes, also update the corresponding entries in 'deploy_function_src.yml'.
  entry_point           = "hello_world"

  # trigger_http = true
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = var.trigger_topic_id
  }
  service_account_email = var.service_account_email_cloud_functions
}
