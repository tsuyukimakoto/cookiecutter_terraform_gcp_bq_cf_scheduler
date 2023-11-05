output "service_account_email_cloud_functions" {
  value = google_service_account.cloud_function_service_account.email
}
output "service_account_email_github_actions" {
  value = google_service_account.github_actions.email
}
output "service_account_id_github_actions" {
  value = google_service_account.github_actions.id
}