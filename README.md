# cookiecutter_terraform_gcp_bq_scheduler

This template facilitates the periodic execution of Cloud Functions through Google Cloud's Cloud Scheduler.

The Cloud Function is designed to export and output the top 10 access data of the week up to the day before the time of execution, based on the data exported daily from GA4.

## How to use

Export the repository (downloading is fine too).

### Using the Sample Python Function

You need to have a setup that exports your GA4 properties to BigQuery on a daily basis (once a day).
It is assumed that [the frequency of data export is set to daily](https://support.google.com/analytics/answer/9823238?sjid=1396493425660618586-AP#step3&zippy=%2Cこの記事の内容).

### Creating Symlinks

For environments other than `dev`, symlinks are utilized to apply common settings.

```bash
cd tf/shared
chmod 755 ./mk_symlink.sh
./mk_symlink.sh
```

### Code Modification

1. `tf/environment/dev/dev_main.tf`
   - Modify the name of the bucket in `backend "gcs"` as appropriate.
2. `tf/environment/dev/dev_vars.tf`
   - Change `project_id` to your Google Cloud Project name.
   - Update `repo_name` to the name of the repository where you pushed the exported project.
   - Adjust `bigquery_dataset_id` to the dataset id of BigQuery linked with GA4.

You may also want to fix other sections that are commented with 'FIXME'.

### Create a Bucket for State Storage in Your Google Cloud Project

Create a bucket with the name you decided in the code modification step 1, using the Google Cloud Console or the gcloud command.

## Preparation for Terraform

The usage is described with the assumption of being used on a Mac.

If you're familiar with the process, feel free to skip this section.

### Installation and Initial Configuration of Terraform & Google Cloud CLI

1. Install Terraform

    ```sh
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ```

2. Install Google Cloud SDK

    ```sh
    brew install --cask google-cloud-sdk
    ```

3. Initial Configuration of gcloud

    Initialize the Google Cloud SDK.

    ```sh
    gcloud init
    ```

4. Authentication

    ```sh
    gcloud auth application-default login
    ```

### terraform apply

Run `terraform init` followed by `terraform apply`. Initially, the deployment of cloud functions will fail due to the absence of source, but don't worry about it.

## Setting Up GitHub Actions

Set the following in the secrets of GitHub Actions. Some can be found after applying terraform, so refer to the Google Cloud console as needed.

### GCP_PROJECT_ID

Set the Google Cloud project you are using.

### GCS_BUCKET

Set the GCS bucket name that stores the cloud functions code.

It's a bucket that includes the name cloud-functions-source-bucket followed by a 16-character random string.

### PUBSUB_TOPIC_ID

Set the Pub/Sub Topic ID.

It's a Topic ID that includes the name cfunction_default_topic followed by a 16-character random string.

### DATASET_ID

Set the ID of the DATASET created in conjunction with GA4. You may not know this until the day after the linkage settings are made.

It's an ID like analytics_000000000. The GCP project name is not required.

### WIF_PROVIDER

In the Google Cloud Console, go to Workload Identity Federation → GitHub Actions Pool and in the editing screen for provider github-actions, set the string displayed as the default audience.

Set from the beginning of projects to the end as shown below.

    `https://iam.googleapis.com/projects/0000.......`

### WIF_SERVICE_ACCOUNT

In Google Cloud Console, go to IAM → Service Accounts, and set the GitHub Actions Deploy Service Account as a service account in email address format.

## Reflecting Changes to the Function

Pushing changes under src will deploy the code to Cloud Functions via GitHub Actions.

There are various hardcoded elements in the GitHub Actions workflow, so modify them as needed.
