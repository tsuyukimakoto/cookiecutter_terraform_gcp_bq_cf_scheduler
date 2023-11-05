variable "project_id" {
  description = "GCPのプロジェクトID"
  default     = "your-gcp-project-name" # FIXME
}
variable "issuer_url" {
  default = "https://token.actions.githubusercontent.com"
}
variable "repo_name" {
  default = "your_github_account/cookiecutter_terraform_gcp_bq_fc_scheduler" # FIXME your github repository name
}
variable "bigquery_dataset_id" {
  default = "analytics_000000000" # FIXME your bigquery dataset id
}
