# EC2 Auto Scaling
- VPC上に配置したEC2インスタンスの負荷の増減に合わせて自動的にEC2インスタンスを増減させる
- CloudWacthでターゲット超過を検知し、ELBに対してスケールアウト/スケールインを指示する
- インスタンスに対するヘルスチェックを行い、インスタアンスが正常ではない場合
  問題のあるインスタンスを削除して新しいインスタンスを起動する
  - EC2ヘルスチェック
  - ELBヘルスチェック

## 構成要素
### Auto Scaling Group
- Auto Scalingの設定の単位 / スケーリングに関わる全般設定を定義したグループ
  - 起動するインスタンスを配置するVPCおよびサブネット
  - インスタンスの配置数の最小値・最大値・希望値 (Desired Capacity)
  - Scaling Plan
  - ヘルスチェック方法
- Auto Scaling Groupに組み込まれたインスタンスは定められたライフサイクルに則って実行される

#### スケーリングされたインスタンスのライフサイクル

| ステータス      | 内容                                                                     |
| -               | -                                                                        |
| Pending         | インスタンスの起動や初期化処理を行なっている                             |
| InService       | インスタンスが正常起動されている                                         |
| Terminating     | インスタンスの終了処理を行なっている                                     |
| Terminated      | インスタンスが終了した                                                   |
| Detaching       | インスタンスをAuto Scaling Groupからデタッチ処理している                 |
| Detached        | インスタンスをAuto Scaling Groupからデタッチした                         |
| EnteringStandby | Standbyへの移行                                                          |
| Standby         | インスタンスがAuto Scaling Groupで管理されているが一時的に削除されている |

### Launch Configuration / Launch Template
- Auto Scaling Groupに関連づけられたインスタンスの起動ルールを定めた設定
  (EC2の起動フローの設定内容と同じ)

### Scaling Plan
- インスタンスをスケールするルール
  - 最小台数の位置 (Auto Healing)
  - 手動スケーリング
  - スケジューリング
  - 動的スケーリング
  - 予測スケーリング

## GUI操作によるAUTO SCALING設定
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

## EC2上にRailsアプリケーションの本番環境を構築する
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

## 参照
- [Amazon EC2](https://aws.amazon.com/jp/ec2/?nc2=h_ql_prod_fs_ec2)
- AWSをはじめよう　～AWSによる環境構築を1から10まで～
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [4. Hands-on #1: 初めてのEC2インスタンスを起動する](https://tomomano.github.io/learn-aws-by-coding/#sec_first_ec2)
- AWSの知識地図〜現場必修の基礎から構築・セキュリティまで 2.3
- AWSの基本・仕組み・重要用語が全部わかる教科書 04-02
