resource "google_pubsub_topic" "cfunction_default_topic" {
  name = "${var.project_prefix}cfunction_default_topic"
}

resource "google_cloud_scheduler_job" "scheduler_job" {
  name     = "${var.project_prefix}cfunction_default_job"
  description = "Weekly job to trigger Cloud Function"
  schedule = "0 9 * * 1" # FIXME if you need

  pubsub_target {
    topic_name = google_pubsub_topic.cfunction_default_topic.id
    data       = base64encode("Optional data to send along with the trigger") # FIXME if you need
  }

  time_zone = "Asia/Tokyo" # FIXME if you need
}

resource "google_pubsub_topic_iam_binding" "pubsub_topic_publisher" {
  topic     = google_pubsub_topic.cfunction_default_topic.name
  role      = "roles/pubsub.publisher"
  members   = ["serviceAccount:${var.project_id}@appspot.gserviceaccount.com"]
}