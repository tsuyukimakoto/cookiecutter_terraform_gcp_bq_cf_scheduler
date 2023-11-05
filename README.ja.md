# cookiecutter_terraform_gcp_bq_scheduler

Google CloudのCloud Schedulerを使って、定期的にCloud Functionsの関数を定期実行する雛形です。

Cloud FunctionsはGA4のデータを日毎にエクスポートしたデータの実行時の前日までの1週間分のアクセスデータトップ10を出力する関数です。

## 使い方

リポジトリをexportします（ダウンロードで構いません）

### サンプルのPython関数を使う設定

GA4のプロパティをBigQueryにエクスポートする設定が必要です。
[データのエクスポート頻度を毎日（1日1回）](https://support.google.com/analytics/answer/9823238?sjid=1396493425660618586-AP#step3&zippy=%2Cこの記事の内容)に設定した前提です。

### symlinkの作成

dev以外の環境を作った場合に、共通した設定を利用するためにsymlinkを利用しています。

```
cd tf/shared
chmod 755 ./mk_symlink.sh
./mk_symlink.sh
```

### コードの修正

1. `tf/environment/dev/dev_main.tf`
   - `backend "gcs"` にある bucket の名前を適当に修正してください
2. `tf/environment/dev/dev_vars.tf`
   - `project_id` をGoogle CloudのProject名に修正してください
   - `repo_name` を、exportしたプロジェクトをpushしたリポジトリの名前に修正してください
   - `bigquery_dataset_id` GA4連携したBigQueryのdataset idに修正してください

他にもFIXMEとコメントしてある箇所は修正したくなるかもしれません。

### Google Cloudのプロジェクトにstate保存用のバケットを作成する

コードの修正1で決めた名前のバケットを、Google Cloud Consoleで作成してください。gcloudコマンドを使っても大丈夫です。

## terraformの準備

macでの利用を前提として記述しています。

特段変わったことはないので、わかってる人は飛ばしましょう。

### Terraform・Google Cloud CLIのインストールと初期設定

1. Terraformのインストール

```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. Google Cloud SDKのインストール

```sh
brew install --cask google-cloud-sdk
```

3. gcloudの初期設定

Google Cloud SDKを初期設定します。

```sh
gcloud init
```

4. 認証

```sh
`gcloud auth application-default login
```

### terraform apply

terraform initを実行し、続いてterraform applyを実行する。最初はソースがないので、cloudfunctionsのデプロイに失敗するが気にしない。

## GitHub Actionsの設定

GitHub Actionsのsecretsに以下を設定する。terraformのapplyで名前がわかるものがあるので、terraformをapplyした後にGoogle Cloudのconsoleを参照しながら設定します。

### GCP_PROJECT_ID

利用するGoogle Cloudのprojectを設定します。

### GCS_BUCKET

cloud functionsのコードを格納するgcs bucket名を設定します。

16文字のランダム文字列に続いて cloud-functions-source-bucket という名前が含まれるbucketです。

### PUBSUB_TOPIC_ID

Pub/SubのTopic IDを設定します。

16文字のランダム文字列に続いて cfunction_default_topic という名前が含まれるTopic IDです。

### DATASET_ID

GA4と連携して作成されたDATASETのIDを設定します。連携設定をした次の日にならないとわからないかもしれません。

analytics_000000000 のようなIDです。GCPのプロジェクト名は不要です。

### WIF_PROVIDER

Google Cloud ConsoleでWorkload Identity 連携 → GitHub Actions Poolで、プロバイダ github-actions の編集画面で、デフォルトのオーディエンスに表示されている文字列を設定します。

以下のように表示されている文字列の projects を先頭に末尾までを設定します。

`https://iam.googleapis.com/projects/0000.......`

### WIF_SERVICE_ACCOUNT

Google Cloud Console で IAM → サービスアカウントで、 GitHub Actions Deploy Service Account のサービスアカウントをメールアドレス形式で設定します。

## 関数の修正を反映する

src以下の変更をpushすると、GitHub ActionsでCloud Functionsにコードがデプロイされます。

GitHub Actionsのworkflowにはハードコードされているものがいろいろありますので、必要に応じて修正してください。
