# Amazone RDS
- フルマネージドRDB (CA型)
- 使用可能なDBエンジン: Amazon Aurora / PostgreSQL / MySQL / MariaDB / Oracle / SQL Server

#### マネージドサービスとしてサポートする機能
- スケールアップ・スケールダウン
- 自動フェイルオーバー - 稼働中のシステムがダウンした際に待機系のシステムへ自動的に切り替え
  - RDSはプライマリ・スタンバイが同じDBエンドポイントを使用するため参照側でエンドポイントの切り替えが不要
  - Multi-AZ配置オプション - 別のAZにスタンバイDBを配置するオプション
- 自動バックアップ - DBスナップショット (毎日) 及びトランザクションログ (5分ごと) をS3へ自動的に保存
- DBパッチ適用 - DBエンジンのアップデートを自動的に実行
- OSパッチ適用 - OSのソフトウェアアップデートを自動的に実行

#### RDSで作成したリードレプリカがサポートする機能
- 読み込みアクセスが遅い場合、最大5台までリードレプリカを構築し負荷分散が可能
- リードレプリカをスタンドアロンDBインスタンスへ昇格可能
- 災害対策等用途で別のリージョンにクロスリージョンリードレプリカを作成可能

## 起動
1. AWS Management ConsoleやAPIを操作してRDBMSの種類・スペック初期設定を使用し起動する
2. AWS側で起動処理が完了すると接続先のエンドポイント (ドメイン名・ポート番号) が発行される
3. エンドポイントへ接続するとネットワーク越しにRDBMSを使用できる
    - 認証・認可はIAMとRDBMSの認証・認可機構を利用する
    - 接続制御はSecurity Groupを利用する

#### フロー
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

## 参照
- [AWSome Day](https://aws.amazon.com/jp/about-aws/events/awsomeday/)
- DNSをはじめよう ～基礎からトラブルシューティングまで～ 改訂第2版
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- AWSの基本・仕組み・重要用語が全部わかる教科書 06-02
