# Elasticsearch terraform について

- 基本
    - main-common.tf
        - Terraform Configurationを確実に編集すること
    - variable-common.tf
        - Common Variableを間違えないようにする
    - variable-1/2.tf
        - Elasticsearch Localを修正する
        - Elasticsearch Localsのelasticsearch_nameとその関連が全ての共通文字になるので、誤りなく編集する
        - インタンスに合わせてMemory reservation, heap memoryのサイズを間違えないように計算する
    - main-1/2.tf
        - 複数台クラスタの時は、特に変更しない
    

- dataノードのインスタンスタイプをi3シリーズ以外にする場合
    - variable-1/2.tfの、「EC2 Locals」の「Data Node」にBlockを定義してあげて、ディスク容量を確保する
    - 詳しくはコピペ。サンプルは下記の通り

```
    block_device_mappings = [
      {
        device_name     = "/dev/xvda"
        ebs_encrypted   = "false"
        ebs_kms_key_id  = null
        ebs_iops        = null
        ebs_volume_size = "200"
        ebs_volume_type = "gp2"
      }
    ]
```

- シングル起動の場合
    - ベースとなるTerraformより高度になるのでなるべくコピペで作ること
    - discovery_type_singleを間違えないようにする
    - ポイントは、Kibanaの実行ECSクラスタをコントロールすることと、KibanaのSGをDatanodeの起動テンプレートに含むこと
    
- B/G切り替えするときの注意点
    - variables-1.tf, main-1.tfから、variables-2.tf, main-2.tfへの変換は、_1->_2への変更、-1->-2への変更をsedで実施する
    - 上記をミスると、コンフリクトを起こすので注意する。