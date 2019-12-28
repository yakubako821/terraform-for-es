cpf-elasticsearch/datadog
==
cpf-elasticsearch の datadog に関連するリソースを管理するディレクトリ。

initialize terraform
--
tfstate の管理は本番アカウントの S3 バケットにて一元管理。

```shell-session
$ terraform init -backend-config="profile=<<aws profile for production>>"
```

modules
--

### ダッシュボード（`modules/dashboard`）
基本的にテンプレートのみで完結するので、ダッシュボード単位でテンプレートを作成する。

### モニタ（`modules/monitor`）
基本的な項目はテンプレート化し、可変項目を変数として定義する。

クラスタ毎にパラメータを用意（`variables-cpf_es_xxx.tf`）し、そこにアラーム名、クエリ、閾値を定義する。
