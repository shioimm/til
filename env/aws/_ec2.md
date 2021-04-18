# EC2
- 参照: [Amazon EC2](https://aws.amazon.com/jp/ec2/?nc2=h_ql_prod_fs_ec2)
- 参照: AWSをはじめよう　～AWSによる環境構築を1から10まで～
- 参照: サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3

## TL;DR
- AWSの基盤上で任意のOSを実行できるサービス
- OSの実行単位はインスタンスと呼ばれる
  - インスタンスのコピーや破棄を容易に行うことができる
  - サーバーのスケール・冗長化を容易に行うことができる
  - インスタンスのIPアドレスは動的に決定される(起動のたびに異なる)
    - 静的なIPアドレスを使用する場合はElasticIPを使用する

## AMI
- Amazon Machine Image
- OSの起動に利用するイメージ(初期設定済みのサーバーのHDD)
- 誰でも作成・共有可能

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

## Get Started
1. AMIの選択
    - Amazon Machine Image - コンピューティング環境のテンプレート(OS)
2. インスタンスタイプの選択
3. インスタンスの詳細の設定
4. ストレージの追加
    - EBSのボリュームの種類・サイズ
    - EBS - EC2で使用する外部ストレージである
5. タグの追加
    - インスタンスを分類するために使用する
6. セキュリティグループの設定
    - セキュリティグループ - ファイアウォールの設定
7. 確認
8. キーペアのダウンロード
    - キーペア - サーバーに入るための鍵-鍵穴
9. 作成したインスタンスに名前をつける

## EC2 Auto Scaling
### TL;DR
- EC２の負荷の増減に合わせてキャパシティを自動的にスケーリングする
- CloudWacthでターゲット超過を検知し、ELBに対してスケールアウト/スケールインを指示する

### Get Started
1. EC2ダッシュボード
  -> AUTO SCALING/起動設定
  -> 起動設定の作成
2. AMIの選択
3. インスタンスタイプの作成
4. 詳細設定
5. ストレージの追加
6. セキュリティグループの設定
7. 確認 -> 作成
    - 既存のキーペアを選択
8. 起動設定を使用してAuto Scalingグループを作成
9. Auto Scalingグループの詳細設定
10. スケーリングポリシーの設定
11. 通知の設定 -> 通知の追加
12. タグを設定
13. 確認 -> 作成

### SSHログイン時に自作のキーペアを使用する
1. ホストで公開鍵秘密鍵のペアを作成
2. EC2上で`.ssh/xxx`ファイルを生成
    - `.ssh/`の権限を制御
3. `.ssh/xxx`にホストで作成した公開鍵をペースト
    - `.ssh/xxx`の権限を制御

### EC2上にRailsアプリケーションの本番環境を構築する
1. EC2: 環境の設定
    - Git
    - Development Tools(`$ yum -y groupinstall "Development Tools"`)
    - rbenv / ruby-build / Ruby / Bundler
    - PostgresSQL(DB / roleの作成)
    - nginx
    - `fog-aws`他画像関連 / `capistrano`他デプロイ関連
2. EC2: 公開鍵秘密鍵のペアを作成
3. EC2: ドキュメントルートを作成(`/var/www`)
4. ホスト: Capfileを作成
    - `$ bundle exec cap install`
5. ホスト: `/config/deploy/production.rb`の編集
6. EC2: `/etc/nginx/conf.d/xxxx.conf`の作成
    - `upstream` / `server`の設定を追加
7. ホスト: デプロイチェック
    - `$ bundle exec cap production deploy:check`
8. EC2: 環境変数の設定
9. ホスト: デプロイ
    - `$ bundle exec cap production deploy`
