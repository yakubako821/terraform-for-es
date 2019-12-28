# CPF/VS Elasticsearch Terraform

## 概要

- Elasticsearchクラスタを構築するTerraformコード
- CPF/VSで構築するESクラスタは基本このコードで構築する

## 用語

- ES
    - Elasticsearchの略

- ESクラスタ
    - Elasticsearchが分散DBとしてもつ論理クラスタのこと。RDBにおける、DBにあたる。

- Data、Master、Coordinate
    - ESクラスタを組む際に1ノードがもつ役割のこと。`ノード`ごとに役割を持つため、`ノード`付きで使う

- Index
    - ESクラスタ上にある箱のことをいう。RDBにおける、テーブルにあたる。Indexが、レコードをもつ

- xpack
    - Elastic社が出している、Elasticstach関連のオプション機能のようなもの。monitoringやsecurityといった、管理の利便をあげる用途が主。

- kibana
    - Elasticstackの一つ。ESに格納されているデータを可視化し、一部分析や、ES操作を行えるGUIを提供する。

## 構築

### Elasticsearch構成

- 下記を参照
    - https://docs.google.com/presentation/d/1g7dsmDBP3LPaGGSjZYFZxa3TrcD8uVVUuobuPEJKpbQ/edit?usp=sharing

- ESの起動
    - DockerによるコンテナでのES起動。Dockerファイルは、Elastic社公式のイメージをベースに作成している。ESクラスタリングには、DiscoveryというAWS専用のクラスタリングオプションを使用する。Discoveryでは、同ネットワーク内にある同じタグを持つEC2を自動で探し出し、クラスタリングするという仕組みとなる。

- ESが持つ接続エンドポイント
    - 全てのエンドポイントは、LBを構築しており、ドメイン名をRoute53により名前解決をしている。共通のドメイン命名規則をもつ。下記のElasticsearchシートで管理。
    - https://docs.google.com/spreadsheets/d/1rDxD-lfCgIu0X-9A7owjOk4OtdHUPZV-wa32iHeDB-c/edit?usp=sharing

- コンテナの実行権限
    - cpf-terraformでIAMロール作成は一元管理しており、それぞれのESで共通のものを利用する。

- ESのDockerfile
    - ECSのタスクで設定するコンテナで利用するDocker情報は別のリポジトリで管理している。Dockerfile自体をCPFの枠を外して共通化できるようにすることと、terraform管理ではなく、circleciとAWS CLIコマンドを組み合わせた自動デプロイ管理にしたいため、別リポジトリ管理としている。
    - https://github.com/Nikkei/cpf-elasticsearch-docker

- ESの起動オプション
    - Elasticsearchはコマンドのオプションによる設定か、elasticsearch.ymlへの記載により、オプションの設定が洗濯・組み合わせができるようになっているが、この構成では全てを起動コマンドで渡すようにしている。そのため、ECRのDockerfileへは、elasticsearch.ymlは包括せず、ECSのタスク定義の環境変数でセットしている。
    - 起動オプションは、ESバージョンにより微妙に違うので注意

- ログ出力
    - Elasticsearchが標準でもつログは、全てCloudwatsh logのドライバーによりCloudwatch logに出力するようにしている。
    - これは、Datadogへログを送付し、監視自体をDatadogで実施するための処置である

- Xpack
    - 基本的に、xpack monitoringを利用する。

- etc
    - editting...

### AWS構成

- 下記を参照
    - https://docs.google.com/presentation/d/1g7dsmDBP3LPaGGSjZYFZxa3TrcD8uVVUuobuPEJKpbQ/edit?usp=sharing

- 基本的に、EC2を使ったECSクラスタで、DockerによりESを起動する
    - MasterがのるEC2は、IPアドレス指定でインスタンス一台一台を定義して立てているが、Data/CoordinateはEC2オートスケーリンググループ機能を使ってEC2を構築している
- EC2上の初期起動コマンドは、EC2のUser-dataでの管理か、オートスケーリンググループの場合は起動テンプレートへの記載で実現している
- 上記で作ったEC2をECSクラスタにECSインスタンスとして登録し、DAEMON起動で設定されているECSサービスが、登録されているEC2上にDockerを起動し、管理する
    - ECSクラスタは、そこに載るECSタスクの起動時オプションを微妙に変える必要があるため、ESの役割ごとに作成する。例えば、Master用のECSクラスタにはMaster用のタスクが、Dataノード用のECSクラスタにはDataノード用のタスクが、EC2 1台につき、1つ起動するように作られている。
- 外部結合ポイントは、ノードが何台だとしてもLBを設定し、Route53で名前変換している

### Terraform詳細

#### バージョン
- https://www.terraform.io/
- 2019年7月現在、バージョン0.12

#### 記述ルール
- https://nikkeidevs.kibe.la/notes/1193
- 社内でまとめている手引きに従って構築する

#### 開発環境
- CPF/VSとして、TerraformのBuild環境を、本番・STG・開発それぞれに用意する

#### ディレクトリ構成
- ホームディレクトリに、案件別のディレクトリを作成する
    - CPFの場合は、記事蓄積（cpf-elasticsearch-article-archive）、記事直近（cpf-elasticsearch-article-recent）、企業人事（cpf-elasticsearch-company-people）の3つが初期案件
- 案件ディレクトリ配下で、環境別を定義する
    - `HOME - 案件名 - aws - env` 配下で必要な環境別にディレクトリを切り、variable.tf, main.tfを配置する。
- ホームディレクトリで案件から分けるか、envディレクトリ配下で分けるか、は作成者自身が決定する

#### Terraform構成
- ※基本的には実際のコードを参照
- `HOME - 案件名 - aws - modules`以下に、構成modulesを記載
- `HOME - 案件名 - aws - env`以下に、実際のvariableとmainを配置する
- 特殊な点
    - IAMロール・IAMユーザはcpf-terraformで共通で作成するため、本terraformではARNだけを連携する
    - B/G構成が取れるように、main.tfは、main-common.tf, main1.tf, main2.tfと、variable-common.tf, variable1.tf, variable2.tfと用意して、1は1系、2は2系を記載している。基本的に2系ファイルは全行コメントアウトしており、必要な時にコメントアウトを外して構築する。

#### modules
- ※実際のコードを参照

- cloudwatch
    - `Cloudwatch log group`を構築する

- ec2
    - Autoscalingグループ、それに伴う起動テンプレートの構築
    - Masterノード用に単純なinstanceの構築もここで記述されている

- ecs_cluster
    - ECSクラスタの構築

- ecs_taskservice
    - ECS task definitionを作成する
    - 作られたECS task definitionを元にしたECS Serviceを作成する

- ecs_taskservice_datadog
    - Datadogエージェント用のmodule

- elb
    - elbを構築

- route53
    - DNSレコードの構築

- security group
    - ESにセットされるsecurity groupを構築

#### main.tf, variable.tf

- main-common.tf
    - ES1系・2系に関わらず共通で設定する必要があるリソースについて記載。
    - SG, Kibanaドメイン用LB,route53がメイン
    - variable-common.tfの変数を読み込む
    - 重要!!!!）アプリケーション向けエンドポイントのRoute53の記述はこちらに記載れているため、applicationエンドポイントを1系・2系で切り替えたいときは、main-common.tfのelasticsearch_route53_record_applicationをで切り替えること。Kibanaも同じ。忘れると、APIが停止することになるので注意する。

- main-1.tf, main-2.tf
    - EC2, Autoscaling group, Launch template, ECS Cluster, ECS Task definition, ECS Service, Cloudwath log group, LB, Route53を構築する
    - variable-1.tf, variable-2.tfに記載の変数を読み込む
    - 1,2系どちらかをオフにしたいときは、基本的に全てコメントアウトすれば良い
    - 重要!!!!）ややこしいが、1系から2系の変数を読んだり、2系のmainで1系とリソースがかち合ってしまうと、Elasticsearchが不正な形でESクラスタを組んでしまい、ESクラスタが破壊されることがあるのでいくつかのポイントについてはミス記載がないように十分注意する

- variable-common.tf
    - ES1系・2系に関わらず共通で設定する必要があるリソースの変数を記載。
    - main-common.tfに読み込まれる
    - Security Groupはここで設定する
    - Elasticsearchの名前をここで記載している。例えば、hogehogeというESを設定すると、1系のESはhogehoge-1、2系はhogehoge-2という名前が自動的につく
    - 重要!!!!）ESの共通名がここで指定されているので、他ESと被らないように注意する

    

- variable-1.tf, variable-2.tf
    - EC2, Autoscaling group, Launch template, ECS Cluster, ECS Task definition, ECS Service, Cloudwath log group, LB, Route53の変数を記載。
    - main-1.tf, main-2.tfに読み込まれる
    - 重要!!!!）ESのスペックを決定するための変数が記載されるので、もっとも手が入るところ。EC2のスペックと、ESの起動時オプションに渡す変数が不整合だと、ESのパフォーマンスが数段落ちたり、不安定になったり、そもそも起動しないこともあるので、十分注意する。

# terraform構築時に注意すること

## 構築時：新規作成時に一度じゃ作りきれない
- （事象）
    - 初期構築時にterraform apply実行をすると、下記のエラーがロードバランサーごとに出力し、いくつかのリソース作成が失敗に終わる
- （対応方法）
    - すぐさま2回目を実行。差分がロードバランサーのAttachのみであることを確認してから実行する。
- （エラーログ）

    ```
    Error: InvalidParameterException: The target group with targetGroupArn arn:aws:elasticloadbalancing:ap-northeast-1:556975058824:targetgroup/cpf-es-cp-m-da-prod-1/377e27f43798cb65 does not have an associated load balancer.
	status code: 400, request id: 6d0d5cc3-ab81-4e4c-83c5-a915df285d2d "cpf-elasticsearch-company-people-monitoring-data-prod-1"
  on ../../../../cpf-elasticsearch-article-archive/aws/modules/ecs_taskservice/ecs_service.tf line 3, in resource "aws_ecs_service" "ecs_service":

   3: resource "aws_ecs_service" "ecs_service" {
Error: InvalidParameterException: The target group with targetGroupArn arn:aws:elasticloadbalancing:ap-northeast-1:556975058824:targetgroup/cpf-es-cp-m-ki-prod-1/34bd782e2b2105f9 does not have an associated load balancer.
	status code: 400, request id: 7e8e5abd-0523-4ff4-8a1f-379d63e860e1 "cpf-elasticsearch-company-people-monitoring-kibana-prod-1"
  on ../../../../cpf-elasticsearch-article-archive/aws/modules/ecs_taskservice/ecs_service.tf line 3, in resource "aws_ecs_service" "ecs_service":
   3: resource "aws_ecs_service" "ecs_service" {
    ```
## 削除時：リソースをDestroyした際、Terraformで削除できないリソースがある
- （事象）クラスタを削除すると、Autoscalingdeあらかじめ確保されている *一部のENIがSGに使われているため削除できない* となる
- （対応方法）削除できないリソースがTerraform画面に表示されるため、手動でENIを削除する


## i3以外のインスタンスを使う場合はRoot Volumeを記載すること

- 本terraformでは、基本的にインスタンスストア（揮発性ディスク）をもつインスタンスタイプを前提に作られている。インスタンスストアであるi3シリーズを利用した場合、EC2は起動時に必要ディスクをマウントし、そのボリュームをESとして利用するため、ルートボリュームは必要ない。逆に、インスタンスストアではないインスタンスを使う場合は、明示的に必要分以上の余裕があるサイズのボリュームを明示的にアタッチしなければならない。
- 本番ESはほとんどi3シリーズを利用するので問題ないが、開発やFS、STGはコスト削減のためi3シリーズを使わない場合の方が多いので、その際はルートボリュームを設定すること忘れないこと。
- 上記の問題は、データボリュームが必要なDataノードのみの問題となる。
- variable-1.tf, variable-2.tfの`launch_template_parameter_data_1 = {`で記載

## シングル構成をする場合は、main-1/2.tfとvariable-1/2.tfを大幅に変更する必要がある

- 複数台構成ではなく、1台構成ESを作るときは、Master/Coordinateノードは全て構築せず、Dataノードを起動数1で設定する。Dataノードの起動オプション設定では、Masterをtrueにしなければならない、IPは固定ではなくていい、などの考慮が必要。
- container_definitionsに記載のJsonファイルも、1台構成用に変更しなければならない。
- したがって、自分から編集するのはむずかしいので、同リポジトリに格納されている`sample-XX`のESモジュールを参考に作ろう。

## ESのスペックの渡し方や、Xpack on/offなど、スペック周りの設定は注意

- insutance_type, memory_reservation, es_java_optsは、なるべく型にはまった計算に従うこと
- `EC2が持っているメモリ`＞`memory_reservationで設定するメモリ`＞`es_java_optsで設定するESのヒープの値`、という順番ではないと、ESが不安定になるか起動しない。
- `-XX:ActiveProcessorCount=4`で設定するCPUコア数を設定する。AWSでいうvCPU数。これを間違えてしまうと、不安定になったり、性能が格段に下がる。
- 逆に、なぜかうまくいかないときは、この部分の記載を怪しむこと。

- monitoringの設定もこちら。

```
    ecr_name_elasticsearch = "cpf-elasticsearch-article"
    ecr_name_kibana        = "cpf-kibana"
    ecr_version            = "v680"

    # single-nodeで起動する場合は、マスターノードのみmaster_node_ipsを1つにして作成し、他ノードの定義を削除して作成する。
    discovery_type_single = false

    # 公式見解 : i3.2xlarge以降は、32766mにヒープメモリを充てるのが最大性能が発揮できる。
    # memory_reservation : インスタンスタイプメモリ - 1024MB
    # -XX:ActiveProcessorCount : インスタンスタイプのvCPU数
    # Xms/Xmx : (memory_reservation - 1G)の70%
    # Xmn : Xms(Xmx) / 2
    master_instance_type      = "t3.small"
    master_node_ips           = list("172.24.68.110", "172.24.76.110", "172.24.84.110")
    master_memory_reservation = 1536
    master_es_java_opts       = "-XX:ActiveProcessorCount=2 -Xms1024m -Xmx1024m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    data_instance_type      = "m5.2xlarge"
    data_autoscaling_size   = 3
    data_memory_reservation = 10240
    data_es_java_opts       = "-XX:ActiveProcessorCount=4 -Xms8192m -Xmx8192m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    kibana-and-coordinate_instance_type    = "m5.large"
    kibana-and-coordinate_autoscaling_size = 1
    coordinate_memory_reservation          = 5120
    kibana_memory_reservation              = 2048
    coordinate_es_java_opts                = "-XX:ActiveProcessorCount=2 -Xms4096m -Xmx4096m -XX:HeapDumpPath=/usr/share/elasticsearch/data -Xlog:gc*:file=/usr/share/elasticsearch/logs/gc_%p_%t.log::filecount=32,filesize=64m:time"

    cluster_routing_allocation_awareness_force_aws_availability_zone_values = "ap-northeast-1a,ap-northeast-1c,ap-northeast-1d"
    xpack_monitoring_collection_enabled                                     = "true"
    xpack_monitoring_exporters_my_remote_host                               = "localhost:9200"
    xpack_monitoring_history_duration                                       = "40d"
    indices_query_bool_max_clause_count                                     = "8192"
```

##### etc
- editting...
