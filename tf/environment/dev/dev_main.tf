# オプション: Google Cloud Storageバケットでの状態の管理
terraform {
  backend "gcs" {
    # This bucket must be created externally, before running 'terraform init'.
    bucket = "ytpbdtbicr-terraform-state-bucket-dev" # FIXME you must change this AND you beed create bucket via cloud console.
    prefix = "terraform/state"
  }
}

resource "random_string" "project_prefix" {
  length  = 16
  upper   = false
  special = false
}

locals {
  project_prefix = "${random_string.project_prefix.result}-"
}

module "service_account" {
  source         = "../../modules/service_account"
  project_prefix = local.project_prefix
}

module "workload_identity" {
  source                            = "../../modules/workload_identity"
  project_id                        = var.project_id
  service_account_id_github_actions = module.service_account.service_account_id_github_actions
  repo_name                         = var.repo_name
}

module "pubsub_scheduler" {
  source         = "../../modules/pubsub"
  project_id     = var.project_id
  project_prefix = local.project_prefix
}

module "cloud_functions" {
  source                                = "../../modules/cloud_functions"
  project_id                            = var.project_id
  project_prefix                        = local.project_prefix
  trigger_topic_id                      = module.pubsub_scheduler.cfunction_default_topic_id
  bigquery_dataset_id                   = var.bigquery_dataset_id
  service_account_email_cloud_functions = module.service_account.service_account_email_cloud_functions
  service_account_email_github_actions  = module.service_account.service_account_email_github_actions
}
