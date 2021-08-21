# EC2
- AWSの基盤上で仮想サーバーを立ち上げるサービス
- 起動状態にある仮想サーバーはインスタンスと呼ばれる
- インスタンスのコピーや破棄を容易に行うことができる
- サーバーのスケール・冗長化を容易に行うことができる
- インスタンスのIPアドレスは動的に決定される(起動のたびに異なる)
  - 静的なIPアドレスを使用する場合はElasticIPを使用する

## AMI
- Amazon Machine Image
- OSに相当する概念であり、ベースとなるOSを選択できる他、
  各種プログラムがインストール済みのAMIも定義することもできる
- OSの起動に利用するイメージ(初期設定済みのサーバーのHDD)
- AWS公式のAMI以外にサードパーティーから提供されているAMIもある

```
# AMIのリストを取得
$ aws ec2 describe-images --owners amazon --profile プロファイル名 --region リージョン
```

## 状態
- Running - 実行中
- Stopped - 停止中
- Terminated - Terminate処理を行った状態・自動的に削除される

## EC2の利用
- EC2上でインスタンスをlaunchするとAWS管理のハードウェア上にAMIが展開され、
  OSが起動し、プライベートIPアドレスが付与される
  - ルートボリューム - AMIを展開するブロックデバイス(EBS)
    - ルートボリュームにはSSHやリモートデスクトップによるネットワークアクセスのみが提供される
- 起動時点でOSのスペック(インスタンスタイプ・ECU)を指定する
  - ECU - CPUパワー
- データの永続化はサポートしておらず別途ストレージ系サービスの利用が必要
- メールを送受信する想定はなく、必要ジアAWSへの申請が必要

### スポットインスタンス
- AWSの余剰リソースを格安で利用できる仕組み
- 長期間稼働を保証しない

## インスタンスタイプ
- 参照: [【AWS】 EC2のインスタンスタイプを解説します。](https://www.acrovision.jp/service/aws/?p=1712)
- CPU、メモリ、ストレージ、ネットワークキャパシティーの組み合わせによって構成され、
  ユースケース別に選択することができる

```
インスタンスファミリー + インスタンス世代 + インスタンスサイズ
```

#### インスタンスファミリー
- T - 汎用
- M - コンピューティング最適化
- C - CPU重視
- R - メモリ重視
- その他

#### インスタンス世代
- 数字が大きい方が世代が新しい

#### インスタンスサイズ
- CPU、メモリ、ネットワークのキャパシティ
- 一段大きくなると、vCPUとメモリサイズが倍になる
  - nano/micro/small/medium/large/xlarge/2xlarge/4xlarge

## 参照
- [Amazon EC2](https://aws.amazon.com/jp/ec2/?nc2=h_ql_prod_fs_ec2)
- AWSをはじめよう　～AWSによる環境構築を1から10まで～
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [4. Hands-on #1: 初めてのEC2インスタンスを起動する](https://tomomano.github.io/learn-aws-by-coding/#sec_first_ec2)
- [6. Hands-on #2: AWS でディープラーニングを実践](https://tomomano.github.io/learn-aws-by-coding/#sec_jupyter_and_deep_learning)
