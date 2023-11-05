resource "google_service_account" "cloud_function_service_account" {
  account_id   = "${var.project_prefix}cfunction-sa"
  display_name = "Cloud Function Service Account"
}

resource "google_service_account" "github_actions" {
  account_id   = "${var.project_prefix}gh-actions"
  display_name = "GitHub Actions Deploy Service Account"
}