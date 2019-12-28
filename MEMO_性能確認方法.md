# CPF ElasticsearchのTerraform
## 構成確認事項とその方法

### Javaが正常に稼働しているか

#### 0) ESの全ての設定を確認
- 全体の設定値をくま幕取得する
- コマンド
```
GET _cluster/settings?include_defaults&flat_settings
```
#### 1) ES JAVA 認識コア数の確認
- コマンド
```
GET _nodes?filter_path=nodes.*.os.*processors
```
- 確認内容
    - available_processorsがインスタンス（ec2）のコア数と合致すること
    - available_processorsは、ESが自動で認識するコア数
    - allocated_processorsは、実際に利用するコア数
    - 自動認識に任せると、available以上のコア数を使わない。

```
<悪い例> 自動認識が1コアしかない
{
 “nodes” : {
   “G96Sep7WTIq7blyiTg5QEg” : {
     “os” : {
       “available_processors” : 1,
       “allocated_processors” : 1
     }
   }...
 }
}

<良い例> 自動認識が2コアで、稼働で利用しているのが2コア
{
 “nodes” : {
   “G96Sep7WTIq7blyiTg5QEg” : {
     “os” : {
       “available_processors” : 2,
       “allocated_processors” : 2
     }
   }...
 }
}
```

- 認識されない場合の対処法
ES起動時に、proseccor=XXで起動オプションをつける。XXにコア数を設定する。

#### 2) 検索性能パラメータ
- コマンド
```
GET _cluster/settings?include_defaults&flat_settings&filter_path=＊.thread_pool\.search＊
```

- 確認内容
    - //キュー最大値
    - "thread_pool.search.max_queue_size" : "1000",
    - //キュー最小値
    - "thread_pool.search.min_queue_size" : "1000",
    - //キュー初期値
    - "thread_pool.search.queue_size" : "1000",
    - //スレッド数（★認識コア数で初期値が変化★）
    - "thread_pool.search.size" : "13",
    - //タスクの目標平均応答時間の閾値。この値を超えるとリジェクトされる。
    - "thread_pool.search.target_response_time" : "1s",
    - 基本はスレッド数がコア数の1.5倍+1あれば十分。特に、キュー最大値は増やせば性能は上がるがヒープを圧迫するので、できるだけ変更しないのが正解。

#### 3) インデクシング性能パラメータ
- コマンド
```
GET _cluster/settings?include_defaults&flat_settings&filter_path=＊.thread_pool\.write＊
```
- 確認内容
    - //キューの最大値
    - "thread_pool.write.queue_size" : "1000",
    - //スレッドの最大数（★認識コア数で初期値が変化★）
    - "thread_pool.write.size" : "8"
    - 基本はスレッド最大値がコア数になっていればOK。インデクシング負荷が高い時、スレッド最大数を下げる。

#### 4) Snapshot性能パラメータ
- コマンド
```
GET _cluster/settings?include_defaults&flat_settings&filter_path=＊.thread_pool\.snapshot＊
```
- 確認内容
    - //Snapshot時のスレッドの最大数（★認識コア数で初期値が変化★）
    - "thread_pool.snapshot.max" : "4",
    - デフォルト値(コア数の半分)でOK。Snapshot頻度が非情に多いなら増やす。


#### 5) Get性能パラメータ（mgetなど）
- コマンド
```
GET _cluster/settings?include_defaults&flat_settings&filter_path=＊.thread_pool\.get＊
```
- 確認内容
    - //キューの最大数
    - "thread_pool.get.queue_size" : "1000",
    - //スレッド最大数（★認識コア数で初期値が変化★）
    - "thread_pool.get.size" : "8",
    - スレッド最大値がコア数になっていればOK。Get頻度が低い時は下げてもよいが、今回、mgetを利用するので、そのままでOK。