# Amazone RDS
- ソース: [AWSome Day](https://aws.amazon.com/jp/about-aws/events/awsomeday/)
- 参照: DNSをはじめよう ～基礎からトラブルシューティングまで～ 改訂第2版
- 参照: サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3

## TL;DR
- AWSクラウド上のフルマネージドRDBMS
- 既存のDBエンジンを使用可能
  - Amazon Aurora/PostgreSQL/MySQL/MariaDB/Oracle/SQL Server
- アプリケーション最適化以外の作業の(バックアップやスケーリング・更新など)を自動で行う
- プライマリDBとスタンバイDBを用意した際、
  スタンバイDBにデータを同期させることで可用性を上げることが可能(マルチAZ配置)
  - プライマリDBとスタンバイDBでアクセスポイントが同じ

## 利用方法
1. AWS Management ConsoleやAPIを操作してRDBMSの種類・スペック初期設定を使用し起動する
2. AWS側で起動処理が完了すると接続先のエンドポイント(ドメイン名・ポート番号)が発行される
3. エンドポイントへ接続するとネットワーク越しにRDBMSを使用できる
    - 認証・認可はIAMとRDBMSの認証・認可機構を利用する
    - 接続制御はSecurity Groupを利用する

## Amazon Aurora
- クラウドに最適化されたAWS独自のRDBMS
  - Amazon Aurora MySQL
  - Amazon Aurora PostgreSQL

## Get Started
1. パラメータグループの作成
    - パラメータ - DBにおける設定値
2. パラメータの編集
    - `utf8mb4`の設定
      character_set_client
      character_set_connection
      character_set_database
      character_set_database
      character_set_server
    - `utf8mb4_general_ci`の設定
      collation_connection
      collation_server
    - `SET NAMES utf8mb4;`の設定
      init_connect
3. オプショングループの作成
4. データベースの作成
    - エンジンの選択
    - 詳細の指定
    - [詳細設定] の設定
5. セキュリティグループでポートを開ける
